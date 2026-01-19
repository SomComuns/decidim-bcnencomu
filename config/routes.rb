# frozen_string_literal: true

require "sidekiq/web"
require "sidekiq/cron/web"

Rails.application.routes.draw do
  authenticate :user, ->(u) { u.admin? } do
    mount Sidekiq::Web => "/sidekiq"
  end

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  # override PasswordController to redirect the user to the first consultation if
  # available
  devise_for :users,
             class_name: "Decidim::User",
             module: :devise,
             router_name: :decidim,
             controllers: {
               invitations: "decidim/devise/invitations",
               sessions: "decidim/devise/sessions",
               confirmations: "decidim/devise/confirmations",
               registrations: "decidim/devise/registrations",
               passwords: "passwords",
               unlocks: "decidim/devise/unlocks",
               omniauth_callbacks: "decidim/devise/omniauth_registrations"
             }
  mount Decidim::Core::Engine => "/"

  # recreates the /assemblies route for /any-alternative, reusing the same controllers
  # content will be differentiatied automatically by scoping selectively all SQL queries depending on the URL prefix
  # if Rails.application.secrets.alternative_assembly_types
  AssembliesScoper.alternative_assembly_types.each do |item|
    resources item[:key], only: [:index, :show], param: :slug, path: item[:key], controller: "decidim/assemblies/assemblies" do
      resources :assembly_members, only: :index, path: "members"
      resource :assembly_widget, only: :show, path: "embed"
    end

    scope "/#{item[:key]}/:assembly_slug/f/:component_id" do
      Decidim.component_manifests.each do |manifest|
        next unless manifest.engine

        constraints Decidim::Assemblies::CurrentComponent.new(manifest) do
          mount manifest.engine, at: "/", as: "decidim_assembly_#{manifest.name}"
        end
      end
    end
  end
  # end
end
