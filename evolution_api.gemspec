# frozen_string_literal: true

require_relative "lib/evolution_api/version"

Gem::Specification.new do |spec|
  spec.name = "evolution_api"
  spec.version = EvolutionApi::VERSION
  spec.authors = ["Evolution API Ruby Client"]
  spec.email = ["support@evolution-api.com"]

  spec.summary = "Cliente Ruby para Evolution API - API de WhatsApp"
  spec.description = "Uma gem Ruby para consumir facilmente a Evolution API, permitindo integração com WhatsApp através de uma API REST simples e poderosa."
  spec.homepage = "https://github.com/tiagotobias2003/evolution_api_ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.glob("{lib,bin}/**/*") + %w[README.md LICENSE.txt CHANGELOG.md]
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "httparty", "~> 0.21"
  spec.add_dependency "json", "~> 2.6"
  spec.add_dependency "dry-configurable", "~> 1.0"
  spec.add_dependency "dry-validation", "~> 1.10"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "webmock", "~> 3.18"
  spec.add_development_dependency "vcr", "~> 6.1"
  spec.add_development_dependency "rubocop", "~> 1.50"
  spec.add_development_dependency "rubocop-rspec", "~> 3.6"
  spec.add_development_dependency "yard", "~> 0.9"
  spec.add_development_dependency "pry", "~> 0.14"
end
