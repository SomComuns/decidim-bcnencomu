# frozen_string_literal: true

require "rails_helper"

describe "Visit_homepage" do
  let(:organization) { create(:organization) }

  let!(:organs) { create(:assemblies_type, id: 17) }

  before do
    switch_to_host(organization.host)
  end

  it "renders the expected menu" do
    visit decidim.root_path

    within ".main-nav" do
      expect(page).to have_content("Inici")
      expect(page).to have_no_content("Espais de participació")
      expect(page).to have_no_content("Òrgans")
      expect(page).to have_content("Consultes")
    end
  end

  context "when there is normal assemblies" do
    let!(:assembly) { create(:assembly, :published, organization: organization) }

    it "renders the expected menu" do
      visit decidim.root_path

      within ".main-nav" do
        expect(page).to have_content("Inici")
        expect(page).to have_content("Espais de participació")
        expect(page).to have_no_content("Òrgans")
        expect(page).to have_content("Consultes")
      end
    end
  end

  context "when there is alternative assemblies" do
    let!(:assembly) { create(:assembly, :published, organization: organization) }
    let!(:assembly2) { create(:assembly, :published, assembly_type: organs, organization: organization) }

    it "renders the expected menu" do
      visit decidim.root_path

      within ".main-nav" do
        expect(page).to have_content("Inici")
        expect(page).to have_content("Espais de participació")
        expect(page).to have_content("Òrgans")
        expect(page).to have_content("Consultes")
      end
    end
  end
end
