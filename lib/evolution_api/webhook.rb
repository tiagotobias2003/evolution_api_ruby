# frozen_string_literal: true

module EvolutionApi
  # Classe para gerenciar webhooks da Evolution API
  class Webhook
    attr_reader :url, :events, :instance_name

    def initialize(data, instance_name = nil)
      @url = data['webhook']
      @events = data['events'] || []
      @instance_name = instance_name
    end

    # Verifica se o webhook está configurado
    def configured?
      !url.nil? && !url.empty?
    end

    # Verifica se um evento específico está habilitado
    def event_enabled?(event)
      events.include?(event)
    end

    # Lista todos os eventos habilitados
    def enabled_events
      events.dup
    end

    # Converte para hash
    def to_h
      {
        url: url,
        events: events,
        configured: configured?,
        instance_name: instance_name
      }
    end

    # Converte para JSON
    def to_json(*args)
      to_h.to_json(*args)
    end
  end
end
