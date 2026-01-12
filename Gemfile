# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

DECIDIM_VERSION = "0.27.5"

gem "decidim", git: "https://github.com/Platoniq/decidim", branch: "v0.27.5-tilelayer-update"
gem "decidim-consultations", DECIDIM_VERSION

gem "decidim-civicrm", git: "https://github.com/Platoniq/decidim-module-civicrm", branch: "main"
gem "decidim-decidim_awesome", git: "https://github.com/Platoniq/decidim-module-decidim_awesome", branch: "0.10.x-leaflet-tilelayer"
gem "decidim-direct_verifications", git: "https://github.com/Platoniq/decidim-verifications-direct_verifications", tag: "v1.3.0"
gem "decidim-term_customizer", git: "https://github.com/mainio/decidim-module-term_customizer", branch: "release/0.27-stable"
gem "omniauth-decidim"

gem "bootsnap", "~> 1.7"
gem "health_check"

gem "puma", ">= 5.0.0"
gem "uglifier", "~> 4.1"

gem "faker", "~> 2.14"
gem "rspec"

gem "image_processing", ">= 1.2"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri
  gem "rubocop-faker"

  gem "decidim-dev", DECIDIM_VERSION
end

group :development do
  gem "letter_opener_web", "~> 1.3"
  gem "listen", "~> 3.1"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console"
end

group :production do
  gem "aws-sdk-s3", require: false
  gem "fog-aws" # to remove once images migrated
  gem "sentry-rails"
  gem "sentry-ruby"
  gem "sidekiq", "~> 6.5"
  gem "sidekiq-cron"
end
