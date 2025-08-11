# frozen_string_literal: true

module EvolutionApi
  # Classe para representar contatos do WhatsApp
  class Contact
    attr_reader :id, :name, :push_name, :verified_name, :is_business, :is_enterprise, :is_high_level_verified,
                :instance_name

    def initialize(data, instance_name = nil)
      @id = data['id']
      @name = data['name']
      @push_name = data['pushName']
      @verified_name = data['verifiedName']
      @is_business = data['isBusiness']
      @is_enterprise = data['isEnterprise']
      @is_high_level_verified = data['isHighLevelVerified']
      @instance_name = instance_name
    end

    # Verifica se é uma conta business
    def business?
      is_business == true
    end

    # Verifica se é uma conta enterprise
    def enterprise?
      is_enterprise == true
    end

    # Verifica se é uma conta verificada de alto nível
    def high_level_verified?
      is_high_level_verified == true
    end

    # Obtém o número do contato (remove sufixos)
    def number
      return nil unless id

      id.split('@').first
    end

    # Obtém o nome de exibição (prioriza nome verificado, depois push name, depois nome)
    def display_name
      verified_name || push_name || name || number
    end

    # Verifica se tem nome verificado
    def verified?
      !verified_name.nil? && !verified_name.empty?
    end

    # Converte para hash
    def to_h
      {
        id: id,
        number: number,
        name: name,
        push_name: push_name,
        verified_name: verified_name,
        display_name: display_name,
        is_business: business?,
        is_enterprise: enterprise?,
        is_high_level_verified: high_level_verified?,
        verified: verified?,
        instance_name: instance_name
      }
    end

    # Converte para JSON
    def to_json(*args)
      to_h.to_json(*args)
    end
  end
end
