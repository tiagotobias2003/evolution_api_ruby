# frozen_string_literal: true

module EvolutionApi
  # Classe para representar chats do WhatsApp
  class Chat
    attr_reader :id, :name, :unread_count, :is_group, :is_read_only, :archived, :pinned, :instance_name

    def initialize(data, instance_name = nil)
      @id = data["id"]
      @name = data["name"]
      @unread_count = data["unreadCount"]
      @is_group = data["isGroup"]
      @is_read_only = data["isReadOnly"]
      @archived = data["archived"]
      @pinned = data["pinned"]
      @instance_name = instance_name
    end

    # Verifica se é um grupo
    def group?
      is_group == true
    end

    # Verifica se é um chat privado
    def private?
      !group?
    end

    # Verifica se tem mensagens não lidas
    def unread?
      unread_count && unread_count > 0
    end

    # Obtém o número de mensagens não lidas
    def unread_count
      @unread_count || 0
    end

    # Verifica se está arquivado
    def archived?
      archived == true
    end

    # Verifica se está fixado
    def pinned?
      pinned == true
    end

    # Verifica se é somente leitura
    def read_only?
      is_read_only == true
    end

    # Obtém o número do chat (remove sufixos)
    def number
      return nil unless id
      id.split("@").first
    end

    # Converte para hash
    def to_h
      {
        id: id,
        name: name,
        number: number,
        unread_count: unread_count,
        is_group: group?,
        is_private: private?,
        is_read_only: read_only?,
        archived: archived?,
        pinned: pinned?,
        instance_name: instance_name
      }
    end

    # Converte para JSON
    def to_json(*args)
      to_h.to_json(*args)
    end
  end
end
