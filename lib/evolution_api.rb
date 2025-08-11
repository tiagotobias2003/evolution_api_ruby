# frozen_string_literal: true

require 'httparty'
require 'json'
require 'dry/configurable'
require 'dry/validation'

require_relative 'evolution_api/version'
require_relative 'evolution_api/client'
require_relative 'evolution_api/instance'
require_relative 'evolution_api/message'
require_relative 'evolution_api/chat'
require_relative 'evolution_api/contact'
require_relative 'evolution_api/webhook'
require_relative 'evolution_api/errors'

# Evolution API Ruby Client
#
# Uma gem Ruby para consumir facilmente a Evolution API,
# permitindo integração com WhatsApp através de uma API REST simples e poderosa.
#
# @example Configuração básica
#   EvolutionApi.configure do |config|
#     config.base_url = "http://localhost:8080"
#     config.api_key = "sua_api_key_aqui"
#   end
#
# @example Uso básico
#   client = EvolutionApi::Client.new
#   instances = client.list_instances
#   client.send_message("instance_name", "5511999999999", "Olá!")
#
# @see https://doc.evolution-api.com/ Evolution API Documentation
module EvolutionApi
  extend Dry::Configurable

  # Configurações padrão
  setting :base_url, default: 'http://localhost:8080'
  setting :api_key, default: nil
  setting :timeout, default: 30
  setting :retry_attempts, default: 3
  setting :retry_delay, default: 1

  # Configuração de webhooks
  setting :webhook_url, default: nil
  setting :webhook_events, default: %w[connection.update message.upsert]

  # Configuração de logs
  setting :logger, default: nil
  setting :log_level, default: :info

  # Configuração de cache
  setting :cache_enabled, default: false
  setting :cache_ttl, default: 300 # 5 minutos

  class << self
    # Configura a gem com as opções fornecidas
    #
    # @param options [Hash] Opções de configuração
    # @yield [config] Bloco para configuração
    # @yieldparam config [Dry::Configurable::Config] Objeto de configuração
    #
    # @example
    #   EvolutionApi.configure do |config|
    #     config.base_url = "https://api.evolution.com"
    #     config.api_key = "sua_chave_api"
    #     config.timeout = 60
    #   end
    def configure(options = {})
      options.each { |key, value| config.public_send("#{key}=", value) }
      yield config if block_given?
    end

    # Retorna um novo cliente configurado
    #
    # @return [EvolutionApi::Client] Cliente configurado
    def client
      @client ||= Client.new
    end

    # Reseta o cliente (útil para testes)
    def reset_client!
      @client = nil
    end
  end
end
