# frozen_string_literal: true

require 'bundler/setup'
require 'dotenv/load'
require 'evolution_api'
require 'webmock/rspec'
require 'vcr'

# Configuração do VCR
VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!

  # Filtrar informações sensíveis
  config.filter_sensitive_data('<API_KEY>') { ENV['EVOLUTION_API_KEY'] }
  config.filter_sensitive_data('<BASE_URL>') { ENV['EVOLUTION_API_BASE_URL'] || 'http://localhost:8080' }

  # Permitir conexões lochas para testes
  config.allow_http_connections_when_no_cassette = true
end

# Configuração do RSpec
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = 'spec/examples.txt'
  config.disable_monkey_patching!
  config.warnings = true

  config.order = :random
  Kernel.srand config.seed

  # Limpar configuração entre testes
  config.before(:each) do
    EvolutionApi.reset_client!
  end
end

# Configuração padrão para testes
EvolutionApi.configure do |config|
  config.base_url = ENV['EVOLUTION_API_BASE_URL'] || 'http://localhost:8080'
  config.api_key = ENV['EVOLUTION_API_KEY']
  config.timeout = 5
  config.retry_attempts = 1
  config.retry_delay = 0.1
end
