# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

Decidim::Shakapacker.register_path("#{base_path}/app/packs")
Decidim::Shakapacker.register_entrypoints(
  decidim_email: "#{base_path}/app/packs/entrypoints/bcnencomu_email.scss",
  fearlesscities_theme: "#{base_path}/app/packs/entrypoints/fearlesscities.scss"
)
