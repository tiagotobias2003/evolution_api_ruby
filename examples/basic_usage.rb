#!/usr/bin/env ruby
# frozen_string_literal: true

# Exemplo básico de uso da Evolution API Ruby Client
require 'dotenv/load'
require 'evolution_api'
require 'cgi'

# Configuração básica
EvolutionApi.configure do |config|
  config.base_url = ENV['EVOLUTION_API_BASE_URL'] || 'http://localhost:8080'
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
    instance_name = instance['name'] || instance['id']
    connection_status = instance['connectionStatus'] || 'N/A'
    profile_name = instance['profileName'] || 'N/A'
    number = instance['number'] || 'N/A'

    puts "  📱 Instância: #{instance_name}"
    puts "     ID: #{instance['id']}"
    puts "     Status: #{connection_status}"
    puts "     Perfil: #{profile_name}"
    puts "     Número: #{number}"
    puts "     Integração: #{instance['integration']}"
    puts "     Mensagens: #{instance['_count']['Message']} | Contatos: #{instance['_count']['Contact']} | Chats: #{instance['_count']['Chat']}"
    puts "     " + "─" * 80
  end

  # 2. Usar uma instância existente
  selected_instance = nil

  if instances.any?
    # Priorizar instâncias conectadas
    connected_instance = instances.find { |i| i['connectionStatus'] == 'open' }
    selected_instance = connected_instance || instances.last

    instance_name = selected_instance['name'] || selected_instance['id']
    puts "\n✅ Usando instância: #{instance_name} (Status: #{selected_instance['connectionStatus']})"
  else
    puts "\n➕ Nenhuma instância encontrada. Criando nova instância..."
    instance_name = ENV['EVOLUTION_API_DEFAULT_INSTANCE'] || 'exemplo_ruby'
    begin
      result = client.create_instance(instance_name, {
        qrcode: true,
        webhook: 'https://seu-webhook.com/evolution'
      })
      puts "Instância criada com sucesso!"
      selected_instance = { 'id' => instance_name, 'name' => instance_name, 'connectionStatus' => 'close' }
    rescue => e
      puts "⚠️  Erro ao criar instância: #{e.message}"
      puts "Saindo do exemplo..."
      return
    end
  end

  # 3. Conectar a instância
  puts "\n🔗 Conectando instância..."
  qr_response = client.connect_instance(selected_instance['name'])
  if qr_response['qrcode']
    puts "QR Code gerado! Escaneie para conectar:"
    puts qr_response['qrcode']
  else
    puts "Instância já conectada!"
  end

  # 4. Verificar status da instância
  puts "\n📊 Verificando status da instância..."
  instance_info = client.get_instance(selected_instance['name'])
  puts "Status: #{instance_info['connectionStatus']}"
  puts "Conectada: #{instance_info['connectionStatus'] == 'open' ? 'Sim' : 'Não'}"

  # 5. Enviar mensagem de teste (se conectada)
  if instance_info['connectionStatus'] == 'open'
    puts "\n💬 Enviando mensagem de teste..."
    #test_number = ENV['TEST_NUMBER'] || '5511999999999'
#
    #response = client.send_text_message(
    #  selected_instance['name'],
    #  test_number,
    #  "Olá! Esta é uma mensagem de teste da Evolution API Ruby Client 🚀 - Disponível em: https://github.com/tiagotobias2003/evolution_api_ruby",
    #  {
    #    "options": {
    #      "preview_url": true
    #    }
    #  }
    #)

    puts "Mensagem enviada com sucesso! TESTE"
    #puts "ID da mensagem: #{response['key']['id']}"
  else
    puts "\n⚠️  Instância não está conectada. Não é possível enviar mensagens."
  end

  # 6. Obter chats
  puts "\n💭 Listando chats da instância #{selected_instance['name']}..."
  chats = client.get_chats(selected_instance['name'])
  puts "Chats encontrados: #{chats.length}"

  puts "listando 5 últimos chats"
  chats.first(5).each do |chat|
    puts "  - #{chat['pushName'] || chat['id']} (#{chat['unreadCount'] || 0} não lidas)"
  end

  # 7. Obter as últimas 5 mensagens do último chat
  puts "\n💭 Listando mensagens do chat #{chats.first['pushName']}..."
  messages = client.get_messages(selected_instance['name'], chats.first['id'], { limit: 5 })
  puts "Mensagens encontradas: #{messages.length}"
  puts messages.first(5).inspect

  # 8. Obter contatos
  puts "\n👥 Listando contatos..."
  contacts = client.get_contacts(selected_instance['name'])
  puts "Contatos encontrados: #{contacts.length}"

  contacts.first(5).each do |contact|
    puts "  - #{contact['name'] || contact['id']}"
  end

  # 9. Configurar webhook
  puts "\n🔗 Configurando webhook..."
  client.set_webhook(
    selected_instance['name'],
    'https://seu-webhook.com/evolution',
    ['connection.update', 'message.upsert']
  )
  puts "Webhook configurado com sucesso!"

  # 10. Usando a classe Instance para operações mais simples
  puts "\n🎯 Usando classe Instance..."
  instance = EvolutionApi::Instance.new(selected_instance['name'], client)

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
