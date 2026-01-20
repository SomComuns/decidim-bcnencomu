# frozen_string_literal: true

Rails.application.config.to_prepare do
  Decidim::Meetings::MeetingsController.class_eval do
    def default_filter_params
      {
        search_text_cont: "",
        with_any_date: %w(all),
        activity: "all",
        with_availability: "",
        with_any_state: nil,
        with_any_origin: nil,
        with_any_type: nil
      }
    end
  end
end
