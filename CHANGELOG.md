# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Versionamento Semântico](https://semver.org/lang/pt-BR/).

## [1.0.0] - 2024-01-XX

### Adicionado
- Cliente Ruby completo para Evolution API
- Suporte a todos os endpoints da Evolution API
- Sistema de configuração flexível com Dry::Configurable
- Tratamento de erros personalizado com exceções específicas
- Retry automático em caso de falhas de rede
- Classes auxiliares para Message, Chat, Contact, Instance e Webhook
- Validação de dados com Dry::Validation
- Documentação completa com YARD
- Testes abrangentes com RSpec e VCR
- Configuração de RuboCop para padrões de código
- Suporte a webhooks
- Gerenciamento completo de instâncias
- Envio de todos os tipos de mensagem (texto, imagem, áudio, vídeo, documento, localização, contato)
- Mensagens interativas (botões e listas)
- Gerenciamento de chats e contatos
- Verificação de números no WhatsApp
- Bloqueio/desbloqueio de contatos

### Características Técnicas
- Ruby 3.0+ como versão mínima
- HTTParty para requisições HTTP
- JSON para serialização
- Configuração via variáveis de ambiente
- Timeout configurável
- Headers personalizáveis
- Logs configuráveis
- Cache opcional

### Documentação
- README completo em português brasileiro
- Exemplos de uso para todos os métodos
- Guia de configuração
- Tratamento de erros
- Guia de testes
- Documentação YARD

### Testes
- Testes unitários para todas as classes
- Testes de integração com VCR
- Cobertura de casos de erro
- Fixtures para testes
- Configuração de ambiente de teste
