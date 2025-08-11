# frozen_string_literal: true

module EvolutionApi
  # Cliente principal para interagir com a Evolution API
  class Client
    include HTTParty

    attr_reader :config

    def initialize(config = nil)
      @config = config || EvolutionApi.config
      setup_http_client
    end

    # ==================== INSTÂNCIAS ====================

    # Lista todas as instâncias
    def list_instances
      get("/instance/fetchInstances")
    end

    # Cria uma nova instância
    def create_instance(instance_name, options = {})
      body = {
        instanceName: instance_name,
        qrcode: options[:qrcode] || true,
        number: options[:number],
        token: options[:token],
        webhook: options[:webhook],
        webhookByEvents: options[:webhook_by_events] || false,
        webhookBase64: options[:webhook_base64] || false
      }.compact

      post("/instance/create", body)
    end

    # Conecta uma instância
    def connect_instance(instance_name)
      post("/instance/connect/#{instance_name}")
    end

    # Desconecta uma instância
    def disconnect_instance(instance_name)
      delete("/instance/logout/#{instance_name}")
    end

    # Remove uma instância
    def delete_instance(instance_name)
      delete("/instance/delete/#{instance_name}")
    end

    # Obtém informações de uma instância
    def get_instance(instance_name)
      get("/instance/fetchInstances/#{instance_name}")
    end

    # Obtém QR Code de uma instância
    def get_qr_code(instance_name)
      get("/instance/connect/#{instance_name}")
    end

    # ==================== MENSAGENS ====================

    # Envia uma mensagem de texto
    def send_text_message(instance_name, number, text, options = {})
      body = {
        number: number,
        text: text,
        options: options
      }

      post("/message/sendText/#{instance_name}", body)
    end

    # Envia uma mensagem de imagem
    def send_image_message(instance_name, number, image_url, caption = nil, options = {})
      body = {
        number: number,
        image: image_url,
        caption: caption,
        options: options
      }.compact

      post("/message/sendImage/#{instance_name}", body)
    end

    # Envia uma mensagem de áudio
    def send_audio_message(instance_name, number, audio_url, options = {})
      body = {
        number: number,
        audio: audio_url,
        options: options
      }

      post("/message/sendAudio/#{instance_name}", body)
    end

    # Envia uma mensagem de vídeo
    def send_video_message(instance_name, number, video_url, caption = nil, options = {})
      body = {
        number: number,
        video: video_url,
        caption: caption,
        options: options
      }.compact

      post("/message/sendVideo/#{instance_name}", body)
    end

    # Envia um documento
    def send_document_message(instance_name, number, document_url, caption = nil, options = {})
      body = {
        number: number,
        document: document_url,
        caption: caption,
        options: options
      }.compact

      post("/message/sendDocument/#{instance_name}", body)
    end

    # Envia uma localização
    def send_location_message(instance_name, number, latitude, longitude, description = nil)
      body = {
        number: number,
        latitude: latitude,
        longitude: longitude,
        description: description
      }.compact

      post("/message/sendLocation/#{instance_name}", body)
    end

    # Envia uma mensagem de contato
    def send_contact_message(instance_name, number, contact_number, contact_name)
      body = {
        number: number,
        contacts: [{
          number: contact_number,
          name: contact_name
        }]
      }

      post("/message/sendContact/#{instance_name}", body)
    end

    # Envia uma mensagem de botão
    def send_button_message(instance_name, number, title, description, buttons)
      body = {
        number: number,
        title: title,
        description: description,
        buttons: buttons
      }

      post("/message/sendButton/#{instance_name}", body)
    end

    # Envia uma lista de opções
    def send_list_message(instance_name, number, title, description, sections)
      body = {
        number: number,
        title: title,
        description: description,
        sections: sections
      }

      post("/message/sendList/#{instance_name}", body)
    end

    # ==================== CHAT ====================

    # Obtém chats de uma instância
    def get_chats(instance_name)
      get("/chat/findChats/#{instance_name}")
    end

    # Obtém mensagens de um chat
    def get_messages(instance_name, number, options = {})
      params = {
        limit: options[:limit] || 50,
        cursor: options[:cursor]
      }.compact

      get("/chat/findMessages/#{instance_name}/#{number}", params)
    end

    # Marca mensagens como lidas
    def mark_messages_as_read(instance_name, number)
      post("/chat/markMessageAsRead/#{instance_name}", { number: number })
    end

    # Arquivar chat
    def archive_chat(instance_name, number)
      post("/chat/archiveChat/#{instance_name}", { number: number })
    end

    # Desarquivar chat
    def unarchive_chat(instance_name, number)
      post("/chat/unarchiveChat/#{instance_name}", { number: number })
    end

    # Deletar chat
    def delete_chat(instance_name, number)
      delete("/chat/deleteChat/#{instance_name}/#{number}")
    end

    # ==================== CONTATOS ====================

    # Obtém contatos de uma instância
    def get_contacts(instance_name)
      get("/contact/findContacts/#{instance_name}")
    end

    # Obtém informações de um contato
    def get_contact(instance_name, number)
      get("/contact/findContact/#{instance_name}/#{number}")
    end

    # Verifica se um número existe no WhatsApp
    def check_number(instance_name, number)
      post("/contact/checkNumber/#{instance_name}", { number: number })
    end

    # Bloqueia um contato
    def block_contact(instance_name, number)
      post("/contact/blockContact/#{instance_name}", { number: number })
    end

    # Desbloqueia um contato
    def unblock_contact(instance_name, number)
      post("/contact/unblockContact/#{instance_name}", { number: number })
    end

    # ==================== WEBHOOK ====================

    # Configura webhook para uma instância
    def set_webhook(instance_name, webhook_url, events = nil)
      body = {
        webhook: webhook_url,
        webhookByEvents: events ? true : false,
        webhookBase64: false
      }

      body[:events] = events if events

      post("/webhook/set/#{instance_name}", body)
    end

    # Obtém configuração de webhook
    def get_webhook(instance_name)
      get("/webhook/find/#{instance_name}")
    end

    # Remove webhook
    def delete_webhook(instance_name)
      delete("/webhook/del/#{instance_name}")
    end

    # ==================== MÉTODOS HTTP ====================

    private

    def setup_http_client
      self.class.base_uri config.base_url
      self.class.timeout config.timeout
      self.class.headers default_headers
    end

    def default_headers
      headers = {
        "Content-Type" => "application/json",
        "Accept" => "application/json"
      }

      headers["apikey"] = config.api_key if config.api_key
      headers
    end

    def get(path, params = {})
      make_request(:get, path, params: params)
    end

    def post(path, body = {})
      make_request(:post, path, body: body)
    end

    def put(path, body = {})
      make_request(:put, path, body: body)
    end

    def delete(path)
      make_request(:delete, path)
    end

    def make_request(method, path, options = {})
      retries = 0
      begin
        response = self.class.public_send(method, path, options)
        handle_response(response)
      rescue HTTParty::Error => e
        retries += 1
        if retries <= config.retry_attempts
          sleep(config.retry_delay)
          retry
        else
          raise ConnectionError, "Erro de conexão após #{config.retry_attempts} tentativas: #{e.message}"
        end
      rescue Net::ReadTimeout, Net::OpenTimeout
        raise TimeoutError, "Timeout na requisição para #{path}"
      end
    end

    def handle_response(response)
      case response.code
      when 200, 201
        parse_response(response)
      when 401
        raise AuthenticationError, "Erro de autenticação", response
      when 403
        raise AuthorizationError, "Acesso negado", response
      when 404
        raise NotFoundError, "Recurso não encontrado", response
      when 422
        raise ValidationError, "Erro de validação", response, parse_errors(response)
      when 429
        raise RateLimitError, "Limite de requisições excedido", response
      when 500..599
        raise ServerError, "Erro interno do servidor", response
      else
        raise Error, "Erro inesperado: #{response.code}", response, response.code
      end
    end

    def parse_response(response)
      return nil if response.body.nil? || response.body.empty?

      JSON.parse(response.body)
    rescue JSON::ParserError
      response.body
    end

    def parse_errors(response)
      return {} unless response.body

      parsed = JSON.parse(response.body)
      parsed["errors"] || parsed
    rescue JSON::ParserError
      { "body" => response.body }
    end
  end
end
