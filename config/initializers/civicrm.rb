# frozen_string_literal: true

Decidim::Civicrm.configure do |config|
  # Configure api credentials
  config.api = {
    key: ENV["CIVICRM_API_KEY"].presence,
    secret: ENV["CIVICRM_API_SECRET"].presence,
    url: ENV["CIVICRM_API_URL"].presence,
    version: ENV.fetch("CIVICRM_API_VERSION", "4")
  }

  # Configure omniauth secrets
  config.omniauth = {
    client_id: ENV["CIVICRM_CLIENT_ID"].presence?,
    client_secret: ENV["CIVICRM_CLIENT_SECRET"].presence,
    site: ENV["CIVICRM_SITE"].presence
  }

  # whether to send notifications to user when they auto-verified or not:
  config.send_verification_notifications = false

  config.send_meeting_registration_notifications = false
end
