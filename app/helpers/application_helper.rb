# frozen_string_literal: true

module ApplicationHelper
  def fearlesscities_site?
    return false unless ENV["FEARLESSCITIES"]

    ENV["FEARLESSCITIES"].include? current_organization&.host&.to_str
  end
end
