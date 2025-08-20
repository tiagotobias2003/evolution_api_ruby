#!/usr/bin/env ruby

# =============================================================================
# EXEMPLO DE INTEGRAÇÃO COM RAILS
# =============================================================================
# Este arquivo demonstra como integrar a gem evolution_api em um projeto Rails
# =============================================================================

# 1. CONFIGURAÇÃO INICIAL
# =======================

# Adicione ao Gemfile:
# gem 'evolution_api'

# Crie o initializer: config/initializers/evolution_api.rb
puts "=== CONFIGURAÇÃO INICIAL ==="
puts "config/initializers/evolution_api.rb:"
puts <<~RUBY
  EvolutionApi.configure do |config|
    config.base_url = Rails.application.credentials.evolution_api[:base_url] || "http://localhost:8080"
    config.api_key = Rails.application.credentials.evolution_api[:api_key]
    config.timeout = 30
    config.retry_attempts = 3
    config.retry_delay = 1
  end
RUBY

puts "\n"

# 2. MODEL EXEMPLO
# ================

puts "=== MODEL EXEMPLO ==="
puts "app/models/whatsapp_message.rb:"
puts <<~RUBY
  class WhatsAppMessage < ApplicationRecord
    validates :instance_name, presence: true
    validates :phone_number, presence: true
    validates :message_type, presence: true, inclusion: { in: %w[text image audio video document] }
    validates :content, presence: true

    after_create :send_to_whatsapp

    private

    def send_to_whatsapp
      client = EvolutionApi.client

      case message_type
      when 'text'
        client.send_text_message(instance_name, phone_number, content)
      when 'image'
        client.send_image_message(instance_name, phone_number, content, caption)
      when 'audio'
        client.send_audio_message(instance_name, phone_number, content)
      when 'video'
        client.send_video_message(instance_name, phone_number, content, caption)
      when 'document'
        client.send_document_message(instance_name, phone_number, content, caption)
      end
    rescue EvolutionApi::Error => e
      update(status: 'failed', error_message: e.message)
    end
  end
RUBY

puts "\n"

# 3. CONTROLLER EXEMPLO
# =====================

puts "=== CONTROLLER EXEMPLO ==="
puts "app/controllers/whatsapp_controller.rb:"
puts <<~RUBY
  class WhatsAppController < ApplicationController
    before_action :set_client

    def index
      @instances = @client.list_instances
    end

    def send_message
      begin
        response = @client.send_text_message(
          params[:instance_name],
          params[:phone_number],
          params[:message]
        )

        render json: { success: true, data: response }
      rescue EvolutionApi::Error => e
        render json: { success: false, error: e.message }, status: :unprocessable_entity
      end
    end

    def list_instances
      instances = @client.list_instances
      render json: { instances: instances }
    end

    def create_instance
      response = @client.create_instance(params[:instance_name], {
        qrcode: true,
        webhook: webhook_url
      })

      render json: { success: true, data: response }
    end

    def qr_code
      qr_data = @client.get_qr_code(params[:instance_name])
      render json: { qr_code: qr_data }
    end

    private

    def set_client
      @client = EvolutionApi.client
    end

    def webhook_url
      # Em um controller Rails real, você usaria:
      # request.base_url + "/webhooks/whatsapp"
      # Para este exemplo, usamos uma URL fixa:
      "https://seu-site.com/webhooks/whatsapp"
    end
  end
RUBY

puts "\n"

# 4. SERVICE OBJECT EXEMPLO
# =========================

puts "=== SERVICE OBJECT EXEMPLO ==="
puts "app/services/whatsapp_service.rb:"
puts <<~RUBY
  class WhatsAppService
    def initialize(instance_name = nil)
      @client = EvolutionApi.client
      @instance_name = instance_name || Rails.application.credentials.evolution_api[:default_instance]
    end

    def send_bulk_messages(phone_numbers, message)
      results = []

      phone_numbers.each do |phone|
        begin
          response = @client.send_text_message(@instance_name, phone, message)
          results << { phone: phone, success: true, response: response }
        rescue EvolutionApi::Error => e
          results << { phone: phone, success: false, error: e.message }
        end
      end

      results
    end

    def broadcast_message(message, options = {})
      contacts = @client.get_contacts(@instance_name)

      contacts.each do |contact|
        next if options[:exclude_numbers]&.include?(contact['id'])

        @client.send_text_message(@instance_name, contact['id'], message)
        sleep(options[:delay] || 1) # Evita rate limiting
      end
    end

    def instance_status
      @client.get_instance(@instance_name)
    end

    def is_connected?
      status = instance_status
      status['status'] == 'open'
    end

    def get_unread_messages
      chats = @client.get_chats(@instance_name)
      unread_chats = chats.select { |chat| chat['unreadCount']&.positive? }

      unread_chats.map do |chat|
        messages = @client.get_messages(@instance_name, { remote_jid: chat['id'], limit: chat['unreadCount'] })
        { chat: chat, messages: messages }
      end
    end
  end
RUBY

puts "\n"

# 5. JOB EXEMPLO
# ==============

puts "=== JOB EXEMPLO ==="
puts "app/jobs/whatsapp_message_job.rb:"
puts <<~RUBY
  class WhatsAppMessageJob < ApplicationJob
    queue_as :whatsapp

    def perform(instance_name, phone_number, message, message_type = 'text')
      client = EvolutionApi.client

      case message_type
      when 'text'
        client.send_text_message(instance_name, phone_number, message)
      when 'image'
        client.send_image_message(instance_name, phone_number, message[:url], message[:caption])
      when 'audio'
        client.send_audio_message(instance_name, phone_number, message[:url])
      when 'video'
        client.send_video_message(instance_name, phone_number, message[:url], message[:caption])
      when 'document'
        client.send_document_message(instance_name, phone_number, message[:url], message[:caption])
      end
    rescue EvolutionApi::Error => error
      Rails.logger.error "WhatsApp message failed: \#{error.message}"
      raise error
    end
  end
RUBY

puts "\n"

# 6. WEBHOOK CONTROLLER EXEMPLO
# =============================

puts "=== WEBHOOK CONTROLLER EXEMPLO ==="
puts "app/controllers/webhooks/whatsapp_controller.rb:"
puts <<~RUBY
  class Webhooks::WhatsappController < ApplicationController
    skip_before_action :verify_authenticity_token

    def receive
      case params[:event]
      when 'connection.update'
        handle_connection_update
      when 'message.upsert'
        handle_message_upsert
      when 'qr.update'
        handle_qr_update
      end

      head :ok
    end

    private

    def handle_connection_update
      instance_name = params[:instance]
      status = params[:data][:status]

      Rails.logger.info "WhatsApp instance \#{instance_name} status: \#{status}"

      # Atualizar status no banco de dados
      instance = WhatsAppInstance.find_by(name: instance_name)
      instance&.update(status: status)
    end

    def handle_message_upsert
      message_data = params[:data]
      instance_name = params[:instance]

      # Processar mensagem recebida
      message = Message.create!(
        instance_name: instance_name,
        phone_number: message_data[:key][:remoteJid],
        message_type: detect_message_type(message_data[:message]),
        content: extract_message_content(message_data[:message]),
        from_me: message_data[:key][:fromMe],
        timestamp: Time.at(message_data[:messageTimestamp])
      )

      # Processar automaticamente se necessário
      AutoReplyService.new(message).process if should_auto_reply?(message)
    end

    def handle_qr_update
      instance_name = params[:instance]
      qr_code = params[:data][:qrcode]

      # Salvar QR code para exibição
      Rails.cache.write("whatsapp_qr_\#{instance_name}", qr_code, expires_in: 2.minutes)
    end

    def detect_message_type(message)
      return 'text' if message[:conversation] || message[:extendedTextMessage]
      return 'image' if message[:imageMessage]
      return 'audio' if message[:audioMessage]
      return 'video' if message[:videoMessage]
      return 'document' if message[:documentMessage]
      return 'location' if message[:locationMessage]
      return 'contact' if message[:contactMessage]
      'unknown'
    end

    def extract_message_content(message)
      return message[:conversation] if message[:conversation]
      return message[:extendedTextMessage][:text] if message[:extendedTextMessage]
      return message[:imageMessage][:url] if message[:imageMessage]
      return message[:audioMessage][:url] if message[:audioMessage]
      return message[:videoMessage][:url] if message[:videoMessage]
      return message[:documentMessage][:url] if message[:documentMessage]
      nil
    end

    def should_auto_reply?(message)
      !message.from_me && message.message_type == 'text'
    end
  end
RUBY

puts "\n"

# 7. ROTAS EXEMPLO
# ================

puts "=== ROTAS EXEMPLO ==="
puts "config/routes.rb:"
puts <<~RUBY
  Rails.application.routes.draw do
    # Rotas para WhatsApp
    resources :whatsapp, only: [:index] do
      collection do
        post :send_message
        get :list_instances
        post :create_instance
        get :qr_code/:instance_name, action: :qr_code, as: :qr_code
      end
    end

    # Webhook para receber mensagens
    post 'webhooks/whatsapp', to: 'webhooks/whatsapp#receive'
  end
RUBY

puts "\n"

# 8. MIGRATION EXEMPLO
# ====================

puts "=== MIGRATION EXEMPLO ==="
puts "db/migrate/YYYYMMDDHHMMSS_create_whatsapp_messages.rb:"
puts <<~RUBY
  class CreateWhatsappMessages < ActiveRecord::Migration[7.0]
    def change
      create_table :whatsapp_messages do |t|
        t.string :instance_name, null: false
        t.string :phone_number, null: false
        t.string :message_type, null: false
        t.text :content, null: false
        t.string :caption
        t.string :status, default: 'pending'
        t.text :error_message
        t.boolean :from_me, default: false
        t.datetime :timestamp
        t.timestamps
      end

      add_index :whatsapp_messages, :instance_name
      add_index :whatsapp_messages, :phone_number
      add_index :whatsapp_messages, :status
    end
  end
RUBY

puts "\n"

# 9. USO PRÁTICO
# ==============

puts "=== USO PRÁTICO ==="
puts "Exemplos de como usar no console Rails:"
puts <<~RUBY
  # No console Rails (rails console)

  # 1. Enviar mensagem simples
  client = EvolutionApi.client
  client.send_text_message('minha_instancia', '5511999999999', 'Olá!')

  # 2. Usar o service
  service = WhatsAppService.new('minha_instancia')
  service.send_bulk_messages(['5511999999999', '5511888888888'], 'Mensagem em massa!')

  # 3. Enviar mensagem assíncrona
  WhatsAppMessageJob.perform_later('minha_instancia', '5511999999999', 'Mensagem assíncrona')

  # 4. Verificar status da instância
  if service.is_connected?
    puts "Instância conectada!"
  else
    puts "Instância desconectada"
  end

  # 5. Obter mensagens não lidas
  unread = service.get_unread_messages
  unread.each do |chat_data|
    puts "Chat: \#{chat_data[:chat]['id']}"
    puts "Mensagens não lidas: \#{chat_data[:messages].length}"
  end
RUBY

puts "\n"

# 10. CONFIGURAÇÃO DE CREDENCIAIS
# ===============================

puts "=== CONFIGURAÇÃO DE CREDENCIAIS ==="
puts "Execute: rails credentials:edit"
puts "Adicione:"
puts <<~YAML
  evolution_api:
    base_url: "https://sua-evolution-api.com"
    api_key: "sua_api_key_aqui"
    default_instance: "minha_instancia"
YAML

puts "\n"

# 11. EXEMPLO COM STIMULUS
# ========================

puts "=== EXEMPLO COM STIMULUS ==="
puts "app/views/whatsapp/index.html.erb:"
puts <<~ERB
  <div class="container" data-controller="whatsapp">
    <h1>WhatsApp Integration</h1>

    <div class="row">
      <div class="col-md-6">
        <h3>Instâncias</h3>
        <button data-action="click->whatsapp#createInstance" class="btn btn-primary">Criar Instância</button>
        <div data-whatsapp-target="instancesList"></div>
      </div>

      <div class="col-md-6">
        <h3>Enviar Mensagem</h3>
        <form data-action="submit->whatsapp#sendMessage">
          <div class="form-group">
            <label>Instância:</label>
            <select data-whatsapp-target="instanceSelect" class="form-control" required>
              <option value="">Selecione uma instância</option>
            </select>
          </div>

          <div class="form-group">
            <label>Número:</label>
            <input type="text" data-whatsapp-target="phoneInput" class="form-control" placeholder="5511999999999" required>
          </div>

          <div class="form-group">
            <label>Mensagem:</label>
            <textarea data-whatsapp-target="messageInput" class="form-control" required></textarea>
          </div>

          <button type="submit" class="btn btn-success">Enviar</button>
        </form>
      </div>
    </div>

    <!-- Área para notificações -->
    <div data-whatsapp-target="notifications"></div>
  </div>
ERB

puts "\n=== CONTROLLER STIMULUS ==="
puts "app/javascript/controllers/whatsapp_controller.js:"
puts <<~JS
  import { Controller } from "@hotwired/stimulus"

  export default class extends Controller {
    static targets = ["instancesList", "instanceSelect", "phoneInput", "messageInput", "notifications"]

    connect() {
      this.loadInstances()
    }

    async loadInstances() {
      try {
        const response = await fetch('/whatsapp/list_instances')
        const data = await response.json()

        this.updateInstancesList(data.instances)
        this.updateInstanceSelect(data.instances)
      } catch (error) {
        this.showNotification('Erro ao carregar instâncias: ' + error.message, 'error')
      }
    }

    updateInstancesList(instances) {
      this.instancesListTarget.innerHTML = instances.map(instance => \`
        <div class="instance">
          <strong>\${instance.instance}</strong>
          <span class="status \${instance.status}">\${instance.status}</span>
          <button data-action="click->whatsapp#connectInstance" data-instance="\${instance.instance}">
            Conectar
          </button>
        </div>
      \`).join('')
    }

    updateInstanceSelect(instances) {
      this.instanceSelectTarget.innerHTML = '<option value="">Selecione uma instância</option>' +
        instances.map(instance => \`
          <option value="\${instance.instance}">\${instance.instance} (\${instance.status})</option>
        \`).join('')
    }

    async sendMessage(event) {
      event.preventDefault()

      const formData = new FormData(event.target)

      try {
        const response = await fetch('/whatsapp/send_message', {
          method: 'POST',
          body: formData,
          headers: {
            'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
          }
        })

        const data = await response.json()

        if (data.success) {
          this.showNotification('Mensagem enviada com sucesso!', 'success')
          event.target.reset()
        } else {
          this.showNotification('Erro ao enviar mensagem: ' + data.error, 'error')
        }
      } catch (error) {
        this.showNotification('Erro de conexão: ' + error.message, 'error')
      }
    }

    async createInstance() {
      const instanceName = prompt('Nome da instância:')
      if (!instanceName) return

      try {
        const response = await fetch('/whatsapp/create_instance', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
          },
          body: JSON.stringify({ instance_name: instanceName })
        })

        const data = await response.json()

        if (data.success) {
          this.showNotification('Instância criada! Verifique o QR Code.', 'success')
          this.loadInstances()
        } else {
          this.showNotification('Erro ao criar instância: ' + data.error, 'error')
        }
      } catch (error) {
        this.showNotification('Erro de conexão: ' + error.message, 'error')
      }
    }

    async connectInstance(event) {
      const instanceName = event.currentTarget.dataset.instance

      try {
        const response = await fetch('/whatsapp/connect_instance', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
          },
          body: JSON.stringify({ instance_name: instanceName })
        })

        const data = await response.json()

        if (data.success && data.qr_code) {
          this.showQRCode(data.qr_code)
          this.showNotification('QR Code gerado! Escaneie com o WhatsApp.', 'info')
        } else {
          this.showNotification('Erro ao conectar instância: ' + data.error, 'error')
        }
      } catch (error) {
        this.showNotification('Erro de conexão: ' + error.message, 'error')
      }
    }

    showQRCode(qrCode) {
      // Implementar exibição do QR Code
      console.log('QR Code:', qrCode)
    }

    showNotification(message, type) {
      const notification = document.createElement('div')
      notification.className = \`alert alert-\${type === 'success' ? 'success' : type === 'error' ? 'danger' : 'info'} alert-dismissible fade show\`
      notification.innerHTML = \`
        \${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
      \`

      this.notificationsTarget.appendChild(notification)

      // Auto-remove após 5 segundos
      setTimeout(() => {
        notification.remove()
      }, 5000)
    }
  }
JS

puts "\n"

puts "=== FIM DO EXEMPLO ==="
puts "Agora você tem um exemplo completo de integração com Rails!"
puts "Para mais informações, consulte o README.md"
