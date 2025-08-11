# frozen_string_literal: true

# Exemplo de integração da Evolution API com Rails
# Este arquivo mostra como integrar a gem em uma aplicação Rails

# 1. Adicione a gem ao Gemfile
=begin
# Gemfile
gem 'evolution_api'
=end

# 2. Configure a gem em config/initializers/evolution_api.rb
=begin
# config/initializers/evolution_api.rb
require 'evolution_api'

EvolutionApi.configure do |config|
  config.base_url = Rails.application.credentials.evolution_api[:base_url]
  config.api_key = Rails.application.credentials.evolution_api[:api_key]
  config.timeout = 30
  config.retry_attempts = 3
  config.retry_delay = 1

  # Configuração de webhook
  config.webhook_url = Rails.application.routes.url_helpers.evolution_webhook_url
  config.webhook_events = ['connection.update', 'message.upsert']

  # Configuração de logs
  config.logger = Rails.logger
  config.log_level = Rails.env.production? ? :warn : :debug
end
=end

# 3. Crie um modelo para gerenciar instâncias
=begin
# app/models/whatsapp_instance.rb
class WhatsAppInstance < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :status, inclusion: { in: %w[open closed connecting] }

  def connected?
    status == 'open'
  end

  def client
    @client ||= EvolutionApi::Client.new
  end

  def instance
    @instance ||= EvolutionApi::Instance.new(name, client)
  end

  def send_message(number, text)
    return false unless connected?

    response = instance.send_text(number, text)
    update(last_message_sent_at: Time.current)
    response
  rescue EvolutionApi::Error => e
    Rails.logger.error "Erro ao enviar mensagem: #{e.message}"
    false
  end

  def refresh_status
    info = client.get_instance(name)
    update(status: info['status'])
  rescue EvolutionApi::Error => e
    Rails.logger.error "Erro ao atualizar status: #{e.message}"
  end
end
=end

# 4. Crie um controller para gerenciar mensagens
=begin
# app/controllers/whatsapp_controller.rb
class WhatsAppController < ApplicationController
  before_action :set_instance

  def send_message
    number = params[:number]
    text = params[:text]

    if @instance.send_message(number, text)
      render json: { success: true, message: 'Mensagem enviada com sucesso' }
    else
      render json: { success: false, message: 'Erro ao enviar mensagem' }, status: :unprocessable_entity
    end
  end

  def qr_code
    qr_response = @instance.client.get_qr_code(@instance.name)
    render json: { qrcode: qr_response['qrcode'] }
  rescue EvolutionApi::Error => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def status
    @instance.refresh_status
    render json: {
      name: @instance.name,
      status: @instance.status,
      connected: @instance.connected?
    }
  end

  private

  def set_instance
    @instance = WhatsAppInstance.find_by!(name: params[:instance_name])
  end
end
=end

# 5. Crie um controller para webhooks
=begin
# app/controllers/evolution_webhook_controller.rb
class EvolutionWebhookController < ApplicationController
  skip_before_action :verify_authenticity_token

  def receive
    event_data = params.permit!.to_h

    case event_data['event']
    when 'connection.update'
      handle_connection_update(event_data)
    when 'message.upsert'
      handle_message_upsert(event_data)
    when 'qr.update'
      handle_qr_update(event_data)
    else
      Rails.logger.info "Evento não tratado: #{event_data['event']}"
    end

    head :ok
  end

  private

  def handle_connection_update(data)
    instance_name = data['instance']
    status = data['data']['state']

    instance = WhatsAppInstance.find_by(name: instance_name)
    return unless instance

    instance.update(status: status)

    Rails.logger.info "Instância #{instance_name} atualizada para status: #{status}"
  end

  def handle_message_upsert(data)
    message_data = data['data']
    instance_name = data['instance']

    # Processar mensagem recebida
    message = EvolutionApi::Message.new(message_data, instance_name)

    # Salvar mensagem no banco de dados
    WhatsAppMessage.create!(
      instance_name: instance_name,
      from: message.from,
      message_type: message.type,
      content: message.text,
      timestamp: message.timestamp,
      raw_data: message_data
    )

    # Processar comando se for uma mensagem de texto
    if message.text? && message.text.start_with?('/')
      process_command(message)
    end

    Rails.logger.info "Mensagem recebida de #{message.from}: #{message.text}"
  end

  def handle_qr_update(data)
    instance_name = data['instance']
    qr_code = data['data']['qrcode']

    # Atualizar QR code na interface ou enviar notificação
    Rails.logger.info "QR Code atualizado para instância #{instance_name}"
  end

  def process_command(message)
    command = message.text.downcase.strip

    case command
    when '/help'
      send_help_message(message)
    when '/status'
      send_status_message(message)
    else
      send_unknown_command_message(message)
    end
  end

  def send_help_message(message)
    help_text = <<~TEXT
      🤖 Comandos disponíveis:

      /help - Mostra esta mensagem
      /status - Mostra o status do sistema
      /info - Informações sobre o bot

      Para suporte, entre em contato conosco.
    TEXT

    instance = WhatsAppInstance.find_by(name: message.instance_name)
    instance&.send_message(message.from, help_text)
  end

  def send_status_message(message)
    instance = WhatsAppInstance.find_by(name: message.instance_name)
    return unless instance

    status_text = <<~TEXT
      📊 Status do Sistema:

      Instância: #{instance.name}
      Status: #{instance.status}
      Conectada: #{instance.connected? ? 'Sim' : 'Não'}
      Última mensagem: #{instance.last_message_sent_at&.strftime('%d/%m/%Y %H:%M') || 'Nunca'}
    TEXT

    instance.send_message(message.from, status_text)
  end

  def send_unknown_command_message(message)
    unknown_text = "❌ Comando não reconhecido. Digite /help para ver os comandos disponíveis."

    instance = WhatsAppInstance.find_by(name: message.instance_name)
    instance&.send_message(message.from, unknown_text)
  end
end
=end

# 6. Adicione as rotas
=begin
# config/routes.rb
Rails.application.routes.draw do
  # Rotas para WhatsApp
  resources :whatsapp_instances, only: [:index, :show] do
    member do
      post :send_message
      get :qr_code
      get :status
    end
  end

  # Webhook da Evolution API
  post '/evolution/webhook', to: 'evolution_webhook#receive'
end
=end

# 7. Crie as migrações necessárias
=begin
# db/migrate/YYYYMMDDHHMMSS_create_whatsapp_instances.rb
class CreateWhatsappInstances < ActiveRecord::Migration[7.0]
  def change
    create_table :whatsapp_instances do |t|
      t.string :name, null: false
      t.string :status, default: 'closed'
      t.datetime :last_message_sent_at
      t.json :metadata

      t.timestamps
    end

    add_index :whatsapp_instances, :name, unique: true
    add_index :whatsapp_instances, :status
  end
end

# db/migrate/YYYYMMDDHHMMSS_create_whatsapp_messages.rb
class CreateWhatsappMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :whatsapp_messages do |t|
      t.string :instance_name, null: false
      t.string :from, null: false
      t.string :message_type
      t.text :content
      t.datetime :timestamp
      t.json :raw_data

      t.timestamps
    end

    add_index :whatsapp_messages, :instance_name
    add_index :whatsapp_messages, :from
    add_index :whatsapp_messages, :timestamp
  end
end
=end

# 8. Exemplo de uso em um job
=begin
# app/jobs/whatsapp_notification_job.rb
class WhatsAppNotificationJob < ApplicationJob
  queue_as :default

  def perform(instance_name, number, message)
    instance = WhatsAppInstance.find_by(name: instance_name)
    return unless instance&.connected?

    instance.send_message(number, message)
  rescue EvolutionApi::Error => e
    Rails.logger.error "Erro no job de notificação WhatsApp: #{e.message}"
    retry_job wait: 5.minutes
  end
end

# Uso:
# WhatsAppNotificationJob.perform_later('minha_instancia', '5511999999999', 'Notificação automática!')
=end

# 9. Exemplo de uso em um service
=begin
# app/services/whatsapp_service.rb
class WhatsAppService
  def initialize(instance_name)
    @instance_name = instance_name
    @client = EvolutionApi.client
  end

  def broadcast_message(message, numbers)
    results = []

    numbers.each do |number|
      begin
        response = @client.send_text_message(@instance_name, number, message)
        results << { number: number, success: true, response: response }
      rescue EvolutionApi::Error => e
        results << { number: number, success: false, error: e.message }
      end
    end

    results
  end

  def send_bulk_messages(messages_data)
    results = []

    messages_data.each do |data|
      begin
        response = case data[:type]
        when 'text'
          @client.send_text_message(@instance_name, data[:number], data[:content])
        when 'image'
          @client.send_image_message(@instance_name, data[:number], data[:url], data[:caption])
        when 'document'
          @client.send_document_message(@instance_name, data[:number], data[:url], data[:caption])
        else
          raise ArgumentError, "Tipo de mensagem não suportado: #{data[:type]}"
        end

        results << { number: data[:number], success: true, response: response }
      rescue StandardError => e
        results << { number: data[:number], success: false, error: e.message }
      end
    end

    results
  end

  def get_chat_history(number, limit: 50)
    @client.get_messages(@instance_name, number, limit: limit)
  rescue EvolutionApi::Error => e
    Rails.logger.error "Erro ao obter histórico: #{e.message}"
    []
  end
end

# Uso:
# service = WhatsAppService.new('minha_instancia')
# service.broadcast_message('Anúncio importante!', ['5511999999999', '5511888888888'])
=end

puts "✅ Exemplo de integração com Rails criado!"
puts "📝 Este arquivo mostra como integrar a Evolution API Ruby Client em uma aplicação Rails"
puts "🔧 Inclui exemplos de modelos, controllers, jobs e services"
