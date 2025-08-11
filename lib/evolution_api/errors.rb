# frozen_string_literal: true

module EvolutionApi
  # Classe base para todos os erros da Evolution API
  class Error < StandardError
    attr_reader :response, :status_code, :error_code

    def initialize(message = nil, response = nil, status_code = nil, error_code = nil)
      super(message)
      @response = response
      @status_code = status_code
      @error_code = error_code
    end
  end

  # Erro de autenticação
  class AuthenticationError < Error
    def initialize(message = "Erro de autenticação", response = nil)
      super(message, response, 401)
    end
  end

  # Erro de autorização
  class AuthorizationError < Error
    def initialize(message = "Acesso negado", response = nil)
      super(message, response, 403)
    end
  end

  # Erro de recurso não encontrado
  class NotFoundError < Error
    def initialize(message = "Recurso não encontrado", response = nil)
      super(message, response, 404)
    end
  end

  # Erro de validação
  class ValidationError < Error
    attr_reader :errors

    def initialize(message = "Erro de validação", response = nil, errors = {})
      super(message, response, 422)
      @errors = errors
    end
  end

  # Erro de rate limit
  class RateLimitError < Error
    def initialize(message = "Limite de requisições excedido", response = nil)
      super(message, response, 429)
    end
  end

  # Erro de servidor
  class ServerError < Error
    def initialize(message = "Erro interno do servidor", response = nil)
      super(message, response, 500)
    end
  end

  # Erro de timeout
  class TimeoutError < Error
    def initialize(message = "Timeout na requisição", response = nil)
      super(message, response, nil)
    end
  end

  # Erro de conexão
  class ConnectionError < Error
    def initialize(message = "Erro de conexão", response = nil)
      super(message, response, nil)
    end
  end

  # Erro de instância não conectada
  class InstanceNotConnectedError < Error
    def initialize(instance_name)
      super("Instância '#{instance_name}' não está conectada", nil, nil, "INSTANCE_NOT_CONNECTED")
    end
  end

  # Erro de QR Code expirado
  class QRCodeExpiredError < Error
    def initialize
      super("QR Code expirado", nil, nil, "QR_CODE_EXPIRED")
    end
  end

  # Erro de número inválido
  class InvalidNumberError < Error
    def initialize(number)
      super("Número '#{number}' é inválido", nil, nil, "INVALID_NUMBER")
    end
  end
end
