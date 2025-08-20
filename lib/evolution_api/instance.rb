# frozen_string_literal: true

module EvolutionApi
  # Classe para gerenciar instâncias do WhatsApp
  class Instance
    attr_reader :name, :client

    def initialize(name, client)
      @name = name
      @client = client
    end

    # Obtém informações da instância
    def info
      client.get_instance(name)
    end

    # Conecta a instância
    def connect
      client.connect_instance(name)
    end

    # Desconecta a instância
    def disconnect
      client.disconnect_instance(name)
    end

    # Remove a instância
    def delete
      client.delete_instance(name)
    end

    # Obtém QR Code para conexão
    def qr_code
      client.get_qr_code(name)
    end

    # Verifica se a instância está conectada
    def connected?
      info = self.info
      info['status'] == 'open'
    rescue StandardError
      false
    end

    # Envia uma mensagem de texto
    def send_text(number, text, options = {})
      client.send_text_message(name, number, text, options)
    end

    # Envia uma mensagem de imagem
    def send_image(number, image_url, caption = nil, options = {})
      client.send_image_message(name, number, image_url, caption, options)
    end

    # Envia uma mensagem de áudio
    def send_audio(number, audio_url, options = {})
      client.send_audio_message(name, number, audio_url, options)
    end

    # Envia uma mensagem de vídeo
    def send_video(number, video_url, caption = nil, options = {})
      client.send_video_message(name, number, video_url, caption, options)
    end

    # Envia um documento
    def send_document(number, document_url, caption = nil, options = {})
      client.send_document_message(name, number, document_url, caption, options)
    end

    # Envia uma localização
    def send_location(number, latitude, longitude, description = nil)
      client.send_location_message(name, number, latitude, longitude, description)
    end

    # Envia um contato
    def send_contact(number, contact_number, contact_name)
      client.send_contact_message(name, number, contact_number, contact_name)
    end

    # Envia uma mensagem com botões
    def send_button(number, title, description, buttons)
      client.send_button_message(name, number, title, description, buttons)
    end

    # Envia uma lista de opções
    def send_list(number, title, description, sections)
      client.send_list_message(name, number, title, description, sections)
    end

    # Obtém chats da instância
    def chats
      client.get_chats(name)
    end

    # Obtém mensagens de um chat
    def messages(options = {})
      client.get_messages(name, options)
    end

    # Marca mensagens como lidas
    def mark_as_read(number)
      client.mark_messages_as_read(name, number)
    end

    # Arquivar chat
    def archive_chat(number)
      client.archive_chat(name, number)
    end

    # Desarquivar chat
    def unarchive_chat(number)
      client.unarchive_chat(name, number)
    end

    # Deletar chat
    def delete_chat(number)
      client.delete_chat(name, number)
    end

    # Obtém contatos da instância
    def contacts
      client.get_contacts(name)
    end

    # Obtém informações de um contato
    def contact(number)
      client.get_contact(name, number)
    end

    # Verifica se um número existe no WhatsApp
    def check_number(number)
      client.check_number(name, number)
    end

    # Bloqueia um contato
    def block_contact(number)
      client.block_contact(name, number)
    end

    # Desbloqueia um contato
    def unblock_contact(number)
      client.unblock_contact(name, number)
    end

    # Configura webhook
    def set_webhook(webhook_url, events = nil)
      client.set_webhook(name, webhook_url, events)
    end

    # Obtém configuração de webhook
    def webhook
      client.get_webhook(name)
    end

    # Remove webhook
    def delete_webhook
      client.delete_webhook(name)
    end
  end
end
