#!/usr/bin/env ruby
# frozen_string_literal: true

# Exemplo básico de uso da Evolution API Ruby Client
require 'evolution_api'

# Configuração básica
EvolutionApi.configure do |config|
  config.base_url = ENV['EVOLUTION_API_URL'] || 'http://localhost:8080'
  config.api_key = ENV['EVOLUTION_API_KEY']
  config.timeout = 30
end

# Criar cliente
client = EvolutionApi.client

puts "🚀 Evolution API Ruby Client - Exemplo Básico"
puts "=" * 50

begin
  # 1. Listar instâncias existentes
  puts "\n📋 Listando instâncias..."
  instances = client.list_instances
  puts "Instâncias encontradas: #{instances.length}"

  instances.each do |instance|
    puts "  - #{instance['instance']} (#{instance['status']})"
  end

  # 2. Criar uma nova instância (se não existir)
  instance_name = 'exemplo_ruby'

  unless instances.any? { |i| i['instance'] == instance_name }
    puts "\n➕ Criando nova instância: #{instance_name}"
    client.create_instance(instance_name, {
      qrcode: true,
      webhook: 'https://seu-webhook.com/evolution'
    })
    puts "Instância criada com sucesso!"
  end

  # 3. Conectar a instância
  puts "\n🔗 Conectando instância..."
  qr_response = client.connect_instance(instance_name)

  if qr_response['qrcode']
    puts "QR Code gerado! Escaneie para conectar:"
    puts qr_response['qrcode']
  else
    puts "Instância já conectada!"
  end

  # 4. Verificar status da instância
  puts "\n📊 Verificando status da instância..."
  instance_info = client.get_instance(instance_name)
  puts "Status: #{instance_info['status']}"
  puts "Conectada: #{instance_info['status'] == 'open'}"

  # 5. Enviar mensagem de teste (se conectada)
  if instance_info['status'] == 'open'
    puts "\n💬 Enviando mensagem de teste..."
    test_number = ENV['TEST_NUMBER'] || '5511999999999'

    response = client.send_text_message(
      instance_name,
      test_number,
      "Olá! Esta é uma mensagem de teste da Evolution API Ruby Client 🚀"
    )

    puts "Mensagem enviada com sucesso!"
    puts "ID da mensagem: #{response['key']['id']}"
  else
    puts "\n⚠️  Instância não está conectada. Não é possível enviar mensagens."
  end

  # 6. Obter chats
  puts "\n💭 Listando chats..."
  chats = client.get_chats(instance_name)
  puts "Chats encontrados: #{chats.length}"

  chats.first(5).each do |chat|
    puts "  - #{chat['name'] || chat['id']} (#{chat['unreadCount']} não lidas)"
  end

  # 7. Obter contatos
  puts "\n👥 Listando contatos..."
  contacts = client.get_contacts(instance_name)
  puts "Contatos encontrados: #{contacts.length}"

  contacts.first(5).each do |contact|
    puts "  - #{contact['name'] || contact['id']}"
  end

  # 8. Configurar webhook
  puts "\n🔗 Configurando webhook..."
  client.set_webhook(
    instance_name,
    'https://seu-webhook.com/evolution',
    ['connection.update', 'message.upsert']
  )
  puts "Webhook configurado com sucesso!"

  # 9. Usando a classe Instance para operações mais simples
  puts "\n🎯 Usando classe Instance..."
  instance = EvolutionApi::Instance.new(instance_name, client)

  if instance.connected?
    puts "Instância está conectada!"

    # Enviar mensagem usando a classe Instance
    if ENV['TEST_NUMBER']
      instance.send_text(ENV['TEST_NUMBER'], "Teste usando classe Instance! 🎉")
      puts "Mensagem enviada via classe Instance!"
    end
  else
    puts "Instância não está conectada."
  end

rescue EvolutionApi::NotFoundError => e
  puts "❌ Erro: #{e.message}"
rescue EvolutionApi::AuthenticationError => e
  puts "❌ Erro de autenticação: #{e.message}"
rescue EvolutionApi::ConnectionError => e
  puts "❌ Erro de conexão: #{e.message}"
rescue StandardError => e
  puts "❌ Erro inesperado: #{e.message}"
  puts e.backtrace.first(5)
end

puts "\n✅ Exemplo concluído!"
puts "\n💡 Dicas:"
puts "  - Configure EVOLUTION_API_URL e EVOLUTION_API_KEY como variáveis de ambiente"
puts "  - Configure TEST_NUMBER para testar envio de mensagens"
puts "  - Verifique a documentação em: https://doc.evolution-api.com/"
