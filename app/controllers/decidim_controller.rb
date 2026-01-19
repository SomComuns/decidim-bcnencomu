# frozen_string_literal: true

# Entry point for Decidim. It will use the `DecidimController` as
# entry point, but you can change what controller it inherits from
# so you can customize some methods.
class DecidimController < ApplicationController
  http_basic_authenticate_with name: ENV.fetch("STAGING_USER", nil),
                               password: ENV.fetch("STAGING_PASSWORD", nil),
                               if: -> { request.subdomain == ENV.fetch("STAGING_SUBDOMAIN", nil) if ENV["STAGING_SUBDOMAIN"].present? }
end
