# Guia de Contribuição

Obrigado por considerar contribuir para o Evolution API Ruby Client! 🚀

## Como Contribuir

### 1. Fork e Clone

1. Faça um fork do repositório
2. Clone seu fork localmente:
   ```bash
   git clone https://github.com/seu-usuario/evolution_api_ruby.git
   cd evolution_api_ruby
   ```

### 2. Configuração do Ambiente

1. Instale as dependências:
   ```bash
   bundle install
   ```

2. Configure o ambiente de desenvolvimento:
   ```bash
   # Configure as variáveis de ambiente para testes
   export EVOLUTION_API_URL="http://localhost:8080"
   export EVOLUTION_API_KEY="sua_chave_api"
   ```

### 3. Desenvolvimento

1. Crie uma branch para sua feature:
   ```bash
   git checkout -b feature/nova-funcionalidade
   ```

2. Faça suas alterações seguindo os padrões:
   - Use RuboCop para manter o estilo do código
   - Adicione testes para novas funcionalidades
   - Atualize a documentação quando necessário

3. Execute os testes:
   ```bash
   bundle exec rspec
   bundle exec rubocop
   ```

### 4. Commit e Push

1. Faça commits com mensagens descritivas:
   ```bash
   git commit -m "feat: adiciona nova funcionalidade X"
   ```

2. Push para sua branch:
   ```bash
   git push origin feature/nova-funcionalidade
   ```

### 5. Pull Request

1. Abra um Pull Request no GitHub
2. Descreva suas mudanças detalhadamente
3. Aguarde a revisão e feedback

## Padrões de Código

### Estilo de Código

- Siga as convenções do RuboCop
- Use `frozen_string_literal: true` em todos os arquivos
- Documente métodos públicos com YARD
- Mantenha métodos pequenos e focados

### Testes

- Escreva testes para todas as novas funcionalidades
- Use VCR para testes de integração
- Mantenha a cobertura de testes alta
- Use nomes descritivos para os testes

### Documentação

- Atualize o README.md quando necessário
- Adicione exemplos de uso
- Documente mudanças no CHANGELOG.md
- Use comentários YARD para documentação técnica

## Tipos de Contribuição

### 🐛 Bug Fixes

- Descreva o bug claramente
- Inclua passos para reproduzir
- Adicione testes para evitar regressões

### ✨ Novas Funcionalidades

- Explique o problema que resolve
- Inclua exemplos de uso
- Adicione testes abrangentes

### 📚 Documentação

- Melhore a clareza da documentação
- Adicione exemplos práticos
- Corrija erros ou inconsistências

### 🧪 Testes

- Adicione testes para funcionalidades existentes
- Melhore a cobertura de testes
- Adicione testes de edge cases

## Processo de Review

1. **Code Review**: Todas as mudanças passam por review
2. **CI/CD**: Os testes devem passar automaticamente
3. **Documentação**: A documentação deve estar atualizada
4. **Aprovação**: Pelo menos um maintainer deve aprovar

## Comunicação

- Use Issues para reportar bugs e sugerir features
- Use Discussions para perguntas e discussões gerais
- Seja respeitoso e construtivo
- Use português ou inglês

## Agradecimentos

Obrigado por contribuir para tornar o Evolution API Ruby Client melhor! 🌟

## Licença

Ao contribuir, você concorda que suas contribuições serão licenciadas sob a mesma licença do projeto (MIT).
