# frozen_string_literal: true

module EvolutionApi
  # Classe para representar mensagens do WhatsApp
  class Message
    attr_reader :id, :key, :message, :message_timestamp, :status, :participant, :instance_name

    def initialize(data, instance_name = nil)
      @id = data['id']
      @key = data['key']
      @message = data['message']
      @message_timestamp = data['messageTimestamp']
      @status = data['status']
      @participant = data['participant']
      @instance_name = instance_name
    end

    # Verifica se é uma mensagem de texto
    def text?
      message&.key?('conversation') || message&.key?('extendedTextMessage')
    end

    # Obtém o texto da mensagem
    def text
      return message['conversation'] if message&.key?('conversation')
      return message['extendedTextMessage']['text'] if message&.key?('extendedTextMessage')

      nil
    end

    # Verifica se é uma mensagem de imagem
    def image?
      message&.key?('imageMessage')
    end

    # Obtém informações da imagem
    def image
      return nil unless image?

      message['imageMessage']
    end

    # Verifica se é uma mensagem de áudio
    def audio?
      message&.key?('audioMessage')
    end

    # Obtém informações do áudio
    def audio
      return nil unless audio?

      message['audioMessage']
    end

    # Verifica se é uma mensagem de vídeo
    def video?
      message&.key?('videoMessage')
    end

    # Obtém informações do vídeo
    def video
      return nil unless video?

      message['videoMessage']
    end

    # Verifica se é um documento
    def document?
      message&.key?('documentMessage')
    end

    # Obtém informações do documento
    def document
      return nil unless document?

      message['documentMessage']
    end

    # Verifica se é uma localização
    def location?
      message&.key?('locationMessage')
    end

    # Obtém informações da localização
    def location
      return nil unless location?

      message['locationMessage']
    end

    # Verifica se é um contato
    def contact?
      message&.key?('contactMessage')
    end

    # Obtém informações do contato
    def contact
      return nil unless contact?

      message['contactMessage']
    end

    # Verifica se é uma mensagem de botão
    def button?
      message&.key?('buttonsResponseMessage') || message&.key?('buttonMessage')
    end

    # Obtém informações do botão
    def button
      return message['buttonsResponseMessage'] if message&.key?('buttonsResponseMessage')
      return message['buttonMessage'] if message&.key?('buttonMessage')

      nil
    end

    # Verifica se é uma lista
    def list?
      message&.key?('listResponseMessage') || message&.key?('listMessage')
    end

    # Obtém informações da lista
    def list
      return message['listResponseMessage'] if message&.key?('listResponseMessage')
      return message['listMessage'] if message&.key?('listMessage')

      nil
    end

    # Verifica se é uma mensagem de reação
    def reaction?
      message&.key?('reactionMessage')
    end

    # Obtém informações da reação
    def reaction
      return nil unless reaction?

      message['reactionMessage']
    end

    # Verifica se é uma mensagem de sticker
    def sticker?
      message&.key?('stickerMessage')
    end

    # Obtém informações do sticker
    def sticker
      return nil unless sticker?

      message['stickerMessage']
    end

    # Obtém o número do remetente
    def from
      key['remoteJid']&.split('@')&.first
    end

    # Obtém o ID da mensagem
    def message_id
      key['id']
    end

    # Verifica se é uma mensagem de grupo
    def group?
      key['remoteJid']&.include?('@g.us')
    end

    # Verifica se é uma mensagem de broadcast
    def broadcast?
      key['remoteJid']&.include?('@broadcast')
    end

    # Verifica se é uma mensagem privada
    def private?
      !group? && !broadcast?
    end

    # Verifica se a mensagem foi enviada pelo próprio usuário
    def from_me?
      key['fromMe'] == true
    end

    # Obtém o timestamp da mensagem
    def timestamp
      Time.at(message_timestamp) if message_timestamp
    end

    # Verifica se a mensagem foi lida
    def read?
      status == 'read'
    end

    # Verifica se a mensagem foi entregue
    def delivered?
      status == 'delivered'
    end

    # Verifica se a mensagem foi enviada
    def sent?
      status == 'sent'
    end

    # Verifica se a mensagem falhou
    def failed?
      status == 'failed'
    end

    # Obtém o tipo da mensagem
    def type
      return 'text' if text?
      return 'image' if image?
      return 'audio' if audio?
      return 'video' if video?
      return 'document' if document?
      return 'location' if location?
      return 'contact' if contact?
      return 'button' if button?
      return 'list' if list?
      return 'reaction' if reaction?
      return 'sticker' if sticker?

      'unknown'
    end

    # Converte para hash
    def to_h
      {
        id: id,
        key: key,
        message: message,
        message_timestamp: message_timestamp,
        status: status,
        participant: participant,
        instance_name: instance_name,
        type: type,
        from: from,
        from_me: from_me?,
        group: group?,
        timestamp: timestamp,
        text: text
      }
    end

    # Converte para JSON
    def to_json(*args)
      to_h.to_json(*args)
    end
  end
end
