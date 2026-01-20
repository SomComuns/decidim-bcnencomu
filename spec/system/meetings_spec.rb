# frozen_string_literal: true

require "rails_helper"

describe "Visit_meetings" do
  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let(:meetings_component) { create(:component, manifest_name: "meetings", participatory_space: participatory_process) }
  let!(:past_meeting) { create(:meeting, :past, :published, component: meetings_component) }

  before do
    switch_to_host(organization.host)
    visit main_component_path(meetings_component)
  end

  it "shows past meetings" do
    expect(page).to have_content(past_meeting.title["ca"])
  end
end
