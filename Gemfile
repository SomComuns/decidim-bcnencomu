# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

DECIDIM_VERSION = { github: "decidim/decidim", branch: "release/0.31-stable" }.freeze

gem "decidim", DECIDIM_VERSION
gem "decidim-civicrm", github: "openpoke/decidim-module-civicrm", branch: "release/0.31-stable"
gem "decidim-decidim_awesome", github: "decidim-ice/decidim-module-decidim_awesome", branch: "release/0.31-stable"
gem "decidim-elections", DECIDIM_VERSION
gem "decidim-pokecode", github: "openpoke/decidim-module-pokecode", branch: "release/0.31-stable"
gem "decidim-term_customizer", github: "openpoke/decidim-module-term_customizer", branch: "release/0.31-stable"
# gem "decidim-direct_verifications", git: "https://github.com/Platoniq/decidim-verifications-direct_verifications", tag: "v1.3.0"
gem "omniauth-decidim"

gem "bootsnap", "~> 1.7"

gem "puma", ">= 6.3.1"
gem "uglifier", "~> 4.1"

gem "image_processing", ">= 1.2"

group :development, :test do
  gem "brakeman", "~> 6.1"
  gem "byebug", "~> 11.0", platform: :mri
  gem "decidim-dev", DECIDIM_VERSION
end

group :development do
  gem "letter_opener_web"
  gem "listen", "~> 3.1"
  gem "web-console"
end
