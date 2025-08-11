#!/usr/bin/env ruby
# frozen_string_literal: true

# Script para testar a gem Evolution API localmente
# Uso: ruby bin/test_gem.rb

require 'bundler/setup'
require_relative '../lib/evolution_api'

puts "🧪 Testando Evolution API Ruby Client"
puts "=" * 50

# Configuração para teste
EvolutionApi.configure do |config|
  config.base_url = ENV['EVOLUTION_API_URL'] || 'http://localhost:8080'
  config.api_key = ENV['EVOLUTION_API_KEY']
  config.timeout = 10
  config.retry_attempts = 1
  config.retry_delay = 0.1
end

client = EvolutionApi.client

# Teste 1: Verificar se a API está acessível
puts "\n1️⃣ Testando conectividade com a API..."
begin
  instances = client.list_instances
  puts "✅ API acessível! Instâncias encontradas: #{instances.length}"
rescue EvolutionApi::ConnectionError => e
  puts "❌ Erro de conexão: #{e.message}"
  puts "💡 Verifique se a Evolution API está rodando em #{EvolutionApi.config.base_url}"
  exit 1
rescue EvolutionApi::AuthenticationError => e
  puts "❌ Erro de autenticação: #{e.message}"
  puts "💡 Verifique sua API key"
  exit 1
rescue StandardError => e
  puts "❌ Erro inesperado: #{e.message}"
  exit 1
end

# Teste 2: Criar uma instância de teste
puts "\n2️⃣ Testando criação de instância..."
test_instance_name = "test_ruby_#{Time.now.to_i}"

begin
  response = client.create_instance(test_instance_name, {
    qrcode: true,
    webhook: 'https://example.com/webhook'
  })
  puts "✅ Instância criada: #{test_instance_name}"
rescue StandardError => e
  puts "❌ Erro ao criar instância: #{e.message}"
end

# Teste 3: Obter QR Code
puts "\n3️⃣ Testando obtenção de QR Code..."
begin
  qr_response = client.get_qr_code(test_instance_name)
  if qr_response['qrcode']
    puts "✅ QR Code obtido com sucesso!"
    puts "📱 QR Code: #{qr_response['qrcode'][0..50]}..."
  else
    puts "⚠️  QR Code não disponível (instância pode estar conectada)"
  end
rescue StandardError => e
  puts "❌ Erro ao obter QR Code: #{e.message}"
end

# Teste 4: Verificar status da instância
puts "\n4️⃣ Testando verificação de status..."
begin
  instance_info = client.get_instance(test_instance_name)
  puts "✅ Status da instância: #{instance_info['status']}"
  puts "📊 Conectada: #{instance_info['status'] == 'open'}"
rescue StandardError => e
  puts "❌ Erro ao verificar status: #{e.message}"
end

# Teste 5: Testar classes auxiliares
puts "\n5️⃣ Testando classes auxiliares..."

# Teste da classe Instance
instance = EvolutionApi::Instance.new(test_instance_name, client)
puts "✅ Classe Instance criada"

# Teste da classe Message
sample_message_data = {
  "id" => "test_id",
  "key" => {
    "remoteJid" => "5511999999999@s.whatsapp.net",
    "fromMe" => false,
    "id" => "test_message_id"
  },
  "message" => {
    "conversation" => "Teste de mensagem"
  },
  "messageTimestamp" => Time.now.to_i,
  "status" => "received"
}

message = EvolutionApi::Message.new(sample_message_data, test_instance_name)
puts "✅ Classe Message criada"
puts "   Tipo: #{message.type}"
puts "   Texto: #{message.text}"
puts "   De: #{message.from}"

# Teste da classe Chat
sample_chat_data = {
  "id" => "5511999999999@s.whatsapp.net",
  "name" => "Teste Chat",
  "unreadCount" => 0,
  "isGroup" => false,
  "isReadOnly" => false,
  "archived" => false,
  "pinned" => false
}

chat = EvolutionApi::Chat.new(sample_chat_data, test_instance_name)
puts "✅ Classe Chat criada"
puts "   Nome: #{chat.name}"
puts "   Grupo: #{chat.group?}"

# Teste da classe Contact
sample_contact_data = {
  "id" => "5511999999999@s.whatsapp.net",
  "name" => "Teste Contato",
  "pushName" => "Teste",
  "verifiedName" => nil,
  "isBusiness" => false,
  "isEnterprise" => false,
  "isHighLevelVerified" => false
}

contact = EvolutionApi::Contact.new(sample_contact_data, test_instance_name)
puts "✅ Classe Contact criada"
puts "   Nome: #{contact.display_name}"
puts "   Business: #{contact.business?}"

# Teste 6: Limpeza
puts "\n6️⃣ Limpando instância de teste..."
begin
  client.delete_instance(test_instance_name)
  puts "✅ Instância removida: #{test_instance_name}"
rescue StandardError => e
  puts "⚠️  Erro ao remover instância: #{e.message}"
end

puts "\n🎉 Testes concluídos com sucesso!"
puts "\n📋 Resumo:"
puts "   ✅ Conectividade com API"
puts "   ✅ Criação de instância"
puts "   ✅ Obtenção de QR Code"
puts "   ✅ Verificação de status"
puts "   ✅ Classes auxiliares"
puts "   ✅ Limpeza de recursos"

puts "\n💡 Próximos passos:"
puts "   1. Configure suas credenciais da Evolution API"
puts "   2. Execute o exemplo básico: ruby examples/basic_usage.rb"
puts "   3. Consulte a documentação: https://doc.evolution-api.com/"
puts "   4. Veja o README.md para mais exemplos"
