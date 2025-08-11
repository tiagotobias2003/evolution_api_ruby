# 🚀 Guia para Publicar a Gem no RubyGems

## 📋 Pré-requisitos

1. **Conta no RubyGems**: Crie uma conta em [rubygems.org](https://rubygems.org)
2. **API Key**: Obtenha sua API key no RubyGems
3. **GitHub Token**: Configure o token do GitHub para CI/CD

## 🔧 Configuração

### 1. Configurar API Key do RubyGems

```bash
# Configure sua API key do RubyGems
gem push --key YOUR_API_KEY
```

Ou configure via variável de ambiente:

```bash
export RUBYGEMS_API_KEY="sua_api_key_aqui"
```

### 2. Configurar GitHub Secrets

No repositório GitHub, vá em **Settings > Secrets and variables > Actions** e adicione:

- `RUBYGEMS_API_KEY`: Sua API key do RubyGems

## 📦 Build e Publicação

### 1. Build Local

```bash
# Instalar dependências
bundle install

# Build da gem
bundle exec rake build
```

### 2. Testar Localmente

```bash
# Instalar localmente para teste
bundle exec rake install

# Testar a gem
ruby bin/test_gem.rb
```

### 3. Publicar Manualmente

```bash
# Build
bundle exec rake build

# Publicar
gem push pkg/evolution_api-1.0.0.gem
```

### 4. Publicar via Rake

```bash
# Build e publicar
bundle exec rake release
```

## 🔄 CI/CD Automático

O projeto já está configurado com GitHub Actions para publicação automática:

1. **Push para main**: Dispara o workflow de CI
2. **Testes passam**: Executa os testes em múltiplas versões do Ruby
3. **Build**: Constrói a gem
4. **Publicação**: Publica automaticamente no RubyGems (se configurado)

### Workflow Configurado

```yaml
# .github/workflows/ci.yml
publish:
  needs: test
  runs-on: ubuntu-latest
  if: github.event_name == 'push' && github.ref == 'refs/heads/main'
  
  steps:
  - name: Build and push gem
    run: |
      bundle exec rake build
      gem push pkg/*.gem
    env:
      GEM_HOST_API_KEY: ${{ secrets.RUBYGEMS_API_KEY }}
```

## 🏷️ Versionamento

### 1. Atualizar Versão

```bash
# Editar lib/evolution_api/version.rb
VERSION = "1.0.1"  # Incrementar versão
```

### 2. Criar Tag

```bash
# Commit das mudanças
git add .
git commit -m "feat: bump version to 1.0.1"

# Criar tag
git tag -a v1.0.1 -m "Release v1.0.1"

# Push
git push origin main
git push origin v1.0.1
```

### 3. Release no GitHub

1. Vá para **Releases** no GitHub
2. Clique em **Create a new release**
3. Selecione a tag criada
4. Adicione descrição das mudanças
5. Publique o release

## 📚 Documentação

### 1. Gerar Documentação

```bash
# Gerar documentação YARD
bundle exec yard doc

# Servir localmente
bundle exec yard server
```

### 2. Publicar no GitHub Pages

O workflow `.github/workflows/docs.yml` já está configurado para:

1. Gerar documentação YARD
2. Publicar automaticamente no GitHub Pages
3. URL: `https://tiagotobias2003.github.io/evolution_api_ruby/`

## 🔍 Verificação

### 1. Verificar no RubyGems

Após a publicação, verifique em:
- [rubygems.org/gems/evolution_api](https://rubygems.org/gems/evolution_api)

### 2. Testar Instalação

```bash
# Instalar a gem publicada
gem install evolution_api

# Testar em um projeto novo
irb
> require 'evolution_api'
> EvolutionApi::VERSION
=> "1.0.0"
```

## 🚨 Troubleshooting

### Erro de Autenticação

```bash
# Verificar API key
gem list --remote evolution_api

# Reconfigurar
gem push --key YOUR_API_KEY
```

### Erro de Versão

```bash
# Verificar versão atual
gem list evolution_api

# Desinstalar versão antiga
gem uninstall evolution_api

# Instalar nova versão
gem install evolution_api
```

### Erro de Dependências

```bash
# Verificar dependências
bundle check

# Atualizar dependências
bundle update
```

## 📈 Próximos Passos

1. **Configurar RubyGems API Key** no GitHub Secrets
2. **Fazer push para main** para disparar CI/CD
3. **Verificar publicação** no RubyGems
4. **Testar instalação** em projeto novo
5. **Compartilhar** com a comunidade

## 🎉 Sucesso!

Após seguir estes passos, sua gem estará:

- ✅ Publicada no RubyGems
- ✅ Disponível via `gem install evolution_api`
- ✅ Com CI/CD automático
- ✅ Com documentação no GitHub Pages
- ✅ Pronta para uso pela comunidade

---

**Boa sorte com sua gem! 🚀**
