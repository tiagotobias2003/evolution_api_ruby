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
