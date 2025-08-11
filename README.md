# Evolution API Ruby Client

[![Ruby Version](https://img.shields.io/badge/ruby-3.0+-red.svg)](https://ruby-lang.org)
[![Gem Version](https://img.shields.io/gem/v/evolution_api.svg)](https://rubygems.org/gems/evolution_api)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE.txt)
[![GitHub](https://img.shields.io/badge/github-evolution__api__ruby-black.svg)](https://github.com/tiagotobias2003/evolution_api_ruby)
[![Build Status](https://github.com/tiagotobias2003/evolution_api_ruby/workflows/CI/badge.svg)](https://github.com/tiagotobias2003/evolution_api_ruby/actions)

Uma gem Ruby elegante e poderosa para consumir a [Evolution API](https://doc.evolution-api.com/), permitindo integração fácil com WhatsApp através de uma API REST simples e robusta.

## 🚀 Características

- ✅ **Interface Ruby Nativa**: API limpa e intuitiva
- ✅ **Suporte Completo**: Todos os endpoints da Evolution API
- ✅ **Tratamento de Erros**: Exceções personalizadas e informativas
- ✅ **Configuração Flexível**: Sistema de configuração robusto
- ✅ **Retry Automático**: Tentativas automáticas em caso de falha
- ✅ **Validação**: Validação de dados com Dry::Validation
- ✅ **Documentação Completa**: YARD documentation
- ✅ **Testes Abrangentes**: RSpec com VCR para testes confiáveis

## 📦 Instalação

Adicione a gem ao seu `Gemfile`:

```ruby
gem 'evolution_api'
```

E execute:

```bash
bundle install
```

Ou instale diretamente:

```bash
gem install evolution_api
```

## 🚂 Integração com Rails

### Instalação em Projetos Rails

1. **Adicione a gem ao seu Gemfile:**

```ruby
# Gemfile
gem 'evolution_api'
```

2. **Execute o bundle install:**

```bash
bundle install
```

3. **Configure a gem no initializer:**

```ruby
# config/initializers/evolution_api.rb
EvolutionApi.configure do |config|
  config.base_url = Rails.application.credentials.evolution_api[:base_url] || "http://localhost:8080"
  config.api_key = Rails.application.credentials.evolution_api[:api_key]
  config.timeout = 30
  config.retry_attempts = 3
  config.retry_delay = 1
end
```

4. **Configure as credenciais (Rails 5.2+):**

```bash
rails credentials:edit
```

Adicione no arquivo de credenciais:

```yaml
evolution_api:
  base_url: "https://sua-evolution-api.com"
  api_key: "sua_api_key_aqui"
```

### Exemplo de Controller Rails

```ruby
# app/controllers/whatsapp_controller.rb
class WhatsAppController < ApplicationController
  before_action :set_client

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

  private

  def set_client
    @client = EvolutionApi.client
  end

  def webhook_url
    "#{request.base_url}/webhooks/whatsapp"
  end
end
```

### Exemplo de Model Rails

```ruby
# app/models/whatsapp_message.rb
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
```

### Exemplo de Service Object

```ruby
# app/services/whatsapp_service.rb
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
end
```

### Exemplo de Job para Processamento Assíncrono

```ruby
# app/jobs/whatsapp_message_job.rb
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
  rescue EvolutionApi::Error => e
    Rails.logger.error "WhatsApp message failed: #{e.message}"
    raise e
  end
end
```

### Exemplo de Webhook Controller

```ruby
# app/controllers/webhooks/whatsapp_controller.rb
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
    
    Rails.logger.info "WhatsApp instance #{instance_name} status: #{status}"
    
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
    Rails.cache.write("whatsapp_qr_#{instance_name}", qr_code, expires_in: 2.minutes)
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
```

### Configuração de Rotas

```ruby
# config/routes.rb
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
```

### Exemplo de View

```erb
<!-- app/views/whatsapp/index.html.erb -->
<div class="whatsapp-dashboard">
  <h1>WhatsApp Dashboard</h1>
  
  <div class="instances">
    <h2>Instâncias</h2>
    <div id="instances-list">
      <!-- Será preenchido via JavaScript -->
    </div>
    
    <button onclick="createInstance()">Nova Instância</button>
  </div>
  
  <div class="qr-code" id="qr-code">
    <!-- QR Code será exibido aqui -->
  </div>
  
  <div class="send-message">
    <h2>Enviar Mensagem</h2>
    <form id="message-form">
      <select name="instance_name" required>
        <option value="">Selecione uma instância</option>
      </select>
      
      <input type="tel" name="phone_number" placeholder="Número (ex: 5511999999999)" required>
      
      <textarea name="message" placeholder="Mensagem" required></textarea>
      
      <button type="submit">Enviar</button>
    </form>
  </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
  loadInstances();
  setupMessageForm();
});

function loadInstances() {
  fetch('/whatsapp/list_instances')
    .then(response => response.json())
    .then(data => {
      const instancesList = document.getElementById('instances-list');
      const instanceSelect = document.querySelector('select[name="instance_name"]');
      
      data.instances.forEach(instance => {
        // Atualizar lista de instâncias
        instancesList.innerHTML += `
          <div class="instance">
            <strong>${instance.instance}</strong>
            <span class="status ${instance.status}">${instance.status}</span>
          </div>
        `;
        
        // Atualizar select
        instanceSelect.innerHTML += `
          <option value="${instance.instance}">${instance.instance} (${instance.status})</option>
        `;
      });
    });
}

function setupMessageForm() {
  document.getElementById('message-form').addEventListener('submit', function(e) {
    e.preventDefault();
    
    const formData = new FormData(this);
    
    fetch('/whatsapp/send_message', {
      method: 'POST',
      body: formData
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        alert('Mensagem enviada com sucesso!');
        this.reset();
      } else {
        alert('Erro ao enviar mensagem: ' + data.error);
      }
    });
  });
}

function createInstance() {
  const instanceName = prompt('Nome da instância:');
  if (!instanceName) return;
  
  fetch('/whatsapp/create_instance', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
    },
    body: JSON.stringify({ instance_name: instanceName })
  })
  .then(response => response.json())
  .then(data => {
    if (data.success) {
      alert('Instância criada! Verifique o QR Code.');
      loadInstances();
    } else {
      alert('Erro ao criar instância: ' + data.error);
    }
  });
}
</script>
```

## ⚙️ Configuração

### Configuração Básica

```ruby
require 'evolution_api'

EvolutionApi.configure do |config|
  config.base_url = "http://localhost:8080"  # URL da sua Evolution API
  config.api_key = "sua_api_key_aqui"        # Sua chave API (opcional)
  config.timeout = 30                         # Timeout em segundos
  config.retry_attempts = 3                   # Número de tentativas
  config.retry_delay = 1                      # Delay entre tentativas (segundos)
end
```

### Configuração Avançada

```ruby
EvolutionApi.configure do |config|
  # Configurações básicas
  config.base_url = "https://api.evolution.com"
  config.api_key = "sua_chave_api"
  
  # Configurações de webhook
  config.webhook_url = "https://seu-site.com/webhook"
  config.webhook_events = ["connection.update", "message.upsert"]
  
  # Configurações de log
  config.logger = Rails.logger
  config.log_level = :info
  
  # Configurações de cache
  config.cache_enabled = true
  config.cache_ttl = 300 # 5 minutos
end
```

## 🎯 Uso Básico

### Inicialização do Cliente

```ruby
# Usando o cliente global
client = EvolutionApi.client

# Ou criando uma instância personalizada
client = EvolutionApi::Client.new
```

### Gerenciamento de Instâncias

```ruby
# Listar todas as instâncias
instances = client.list_instances

# Criar uma nova instância
client.create_instance("minha_instancia", {
  qrcode: true,
  webhook: "https://seu-site.com/webhook"
})

# Conectar uma instância
client.connect_instance("minha_instancia")

# Obter QR Code para conexão
qr_code = client.get_qr_code("minha_instancia")

# Verificar status da instância
instance_info = client.get_instance("minha_instancia")
puts "Status: #{instance_info['status']}"

# Desconectar instância
client.disconnect_instance("minha_instancia")

# Remover instância
client.delete_instance("minha_instancia")
```

### Envio de Mensagens

```ruby
# Mensagem de texto
client.send_text_message("minha_instancia", "5511999999999", "Olá! Como vai?")

# Mensagem de imagem
client.send_image_message(
  "minha_instancia", 
  "5511999999999", 
  "https://exemplo.com/imagem.jpg",
  "Legenda da imagem"
)

# Mensagem de áudio
client.send_audio_message(
  "minha_instancia", 
  "5511999999999", 
  "https://exemplo.com/audio.mp3"
)

# Mensagem de vídeo
client.send_video_message(
  "minha_instancia", 
  "5511999999999", 
  "https://exemplo.com/video.mp4",
  "Descrição do vídeo"
)

# Documento
client.send_document_message(
  "minha_instancia", 
  "5511999999999", 
  "https://exemplo.com/documento.pdf",
  "Descrição do documento"
)

# Localização
client.send_location_message(
  "minha_instancia", 
  "5511999999999", 
  -23.5505, 
  -46.6333, 
  "São Paulo, SP"
)

# Contato
client.send_contact_message(
  "minha_instancia", 
  "5511999999999", 
  "5511888888888", 
  "João Silva"
)
```

### Mensagens Interativas

```ruby
# Mensagem com botões
buttons = [
  { id: "btn1", body: "Opção 1" },
  { id: "btn2", body: "Opção 2" },
  { id: "btn3", body: "Opção 3" }
]

client.send_button_message(
  "minha_instancia",
  "5511999999999",
  "Título da mensagem",
  "Descrição da mensagem",
  buttons
)

# Lista de opções
sections = [
  {
    title: "Seção 1",
    rows: [
      { id: "1", title: "Item 1", description: "Descrição 1" },
      { id: "2", title: "Item 2", description: "Descrição 2" }
    ]
  }
]

client.send_list_message(
  "minha_instancia",
  "5511999999999",
  "Título da lista",
  "Descrição da lista",
  sections
)
```

### Gerenciamento de Chats

```ruby
# Obter todos os chats
chats = client.get_chats("minha_instancia")

# Obter mensagens de um chat
messages = client.get_messages("minha_instancia", "5511999999999", {
  limit: 50,
  cursor: "cursor_para_paginacao"
})

# Marcar mensagens como lidas
client.mark_messages_as_read("minha_instancia", "5511999999999")

# Arquivar chat
client.archive_chat("minha_instancia", "5511999999999")

# Desarquivar chat
client.unarchive_chat("minha_instancia", "5511999999999")

# Deletar chat
client.delete_chat("minha_instancia", "5511999999999")
```

### Gerenciamento de Contatos

```ruby
# Obter todos os contatos
contacts = client.get_contacts("minha_instancia")

# Obter informações de um contato específico
contact = client.get_contact("minha_instancia", "5511999999999")

# Verificar se um número existe no WhatsApp
result = client.check_number("minha_instancia", "5511999999999")
puts "Número existe: #{result['exists']}"

# Bloquear contato
client.block_contact("minha_instancia", "5511999999999")

# Desbloquear contato
client.unblock_contact("minha_instancia", "5511999999999")
```

### Configuração de Webhooks

```ruby
# Configurar webhook
client.set_webhook(
  "minha_instancia",
  "https://seu-site.com/webhook",
  ["connection.update", "message.upsert"]
)

# Obter configuração do webhook
webhook_config = client.get_webhook("minha_instancia")

# Remover webhook
client.delete_webhook("minha_instancia")
```

## 🎨 Uso com Classes Auxiliares

### Usando a Classe Instance

```ruby
# Criar uma instância gerenciada
instance = EvolutionApi::Instance.new("minha_instancia", client)

# Verificar se está conectada
if instance.connected?
  puts "Instância conectada!"
  
  # Enviar mensagem
  instance.send_text("5511999999999", "Olá!")
  
  # Obter chats
  chats = instance.chats
  
  # Obter contatos
  contacts = instance.contacts
else
  puts "Instância não conectada"
  qr_code = instance.qr_code
end
```

### Trabalhando com Mensagens

```ruby
# Obter mensagens e processar
messages_data = client.get_messages("minha_instancia", "5511999999999")
messages = messages_data.map { |msg| EvolutionApi::Message.new(msg, "minha_instancia") }

messages.each do |message|
  case message.type
  when "text"
    puts "Texto: #{message.text}"
  when "image"
    puts "Imagem: #{message.image['url']}"
  when "audio"
    puts "Áudio: #{message.audio['url']}"
  end
  
  puts "De: #{message.from}"
  puts "Enviada por mim: #{message.from_me?}"
  puts "Grupo: #{message.group?}"
  puts "Timestamp: #{message.timestamp}"
end
```

### Trabalhando com Chats

```ruby
# Obter chats e processar
chats_data = client.get_chats("minha_instancia")
chats = chats_data.map { |chat| EvolutionApi::Chat.new(chat, "minha_instancia") }

chats.each do |chat|
  puts "Chat: #{chat.name}"
  puts "Número: #{chat.number}"
  puts "Grupo: #{chat.group?}"
  puts "Não lidas: #{chat.unread_count}"
  puts "Arquivado: #{chat.archived?}"
end
```

### Trabalhando com Contatos

```ruby
# Obter contatos e processar
contacts_data = client.get_contacts("minha_instancia")
contacts = contacts_data.map { |contact| EvolutionApi::Contact.new(contact, "minha_instancia") }

contacts.each do |contact|
  puts "Nome: #{contact.display_name}"
  puts "Número: #{contact.number}"
  puts "Business: #{contact.business?}"
  puts "Verificado: #{contact.verified?}"
end
```

## 🚨 Tratamento de Erros

A gem fornece exceções específicas para diferentes tipos de erro:

```ruby
begin
  client.send_text_message("instancia_inexistente", "5511999999999", "Olá!")
rescue EvolutionApi::NotFoundError => e
  puts "Instância não encontrada: #{e.message}"
rescue EvolutionApi::AuthenticationError => e
  puts "Erro de autenticação: #{e.message}"
rescue EvolutionApi::ValidationError => e
  puts "Erro de validação: #{e.message}"
  puts "Detalhes: #{e.errors}"
rescue EvolutionApi::RateLimitError => e
  puts "Rate limit excedido: #{e.message}"
rescue EvolutionApi::ServerError => e
  puts "Erro do servidor: #{e.message}"
rescue EvolutionApi::ConnectionError => e
  puts "Erro de conexão: #{e.message}"
rescue EvolutionApi::TimeoutError => e
  puts "Timeout: #{e.message}"
end
```

## 🧪 Testes

### Executar Testes

```bash
# Executar todos os testes
bundle exec rspec

# Executar testes com coverage
bundle exec rspec --format documentation

# Executar testes específicos
bundle exec rspec spec/evolution_api/client_spec.rb
```

### Exemplo de Teste

```ruby
require 'spec_helper'

RSpec.describe EvolutionApi::Client do
  let(:client) { described_class.new }

  describe '#list_instances' do
    it 'returns list of instances' do
      VCR.use_cassette('list_instances') do
        response = client.list_instances
        expect(response).to be_an(Array)
      end
    end
  end

  describe '#send_text_message' do
    it 'sends text message successfully' do
      VCR.use_cassette('send_text_message') do
        response = client.send_text_message(
          'test_instance',
          '5511999999999',
          'Test message'
        )
        expect(response['status']).to eq('success')
      end
    end
  end
end
```

## 📚 Documentação

A documentação completa está disponível em:

- [Documentação da API](https://doc.evolution-api.com/)
- [Documentação da Gem (YARD)](https://tiagotobias2003.github.io/evolution_api_ruby/)

Para gerar a documentação localmente:

```bash
bundle exec yard doc
bundle exec yard server
```

## 🤝 Contribuindo

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

### Padrões de Código

```bash
# Verificar estilo do código
bundle exec rubocop

# Corrigir automaticamente
bundle exec rubocop -a

# Verificar apenas arquivos modificados
bundle exec rubocop --only-guide-cops
```

## 📄 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE.txt](LICENSE.txt) para detalhes.

## 🆘 Suporte

- 📖 [Documentação](https://doc.evolution-api.com/)
- 🐛 [Issues](https://github.com/tiagotobias2003/evolution_api_ruby/issues)
- 💬 [Discussions](https://github.com/tiagotobias2003/evolution_api_ruby/discussions)

## 🙏 Agradecimentos

- [Evolution API](https://github.com/EvolutionAPI/evolution-api) - API incrível para WhatsApp
- [HTTParty](https://github.com/jnunemaker/httparty) - Cliente HTTP elegante
- [Dry::Configurable](https://dry-rb.org/gems/dry-configurable) - Sistema de configuração
- [Dry::Validation](https://dry-rb.org/gems/dry-validation) - Validação de dados

---

**Desenvolvido com ❤️ para a comunidade Ruby**
