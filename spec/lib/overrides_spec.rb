# frozen_string_literal: true

require "rails_helper"

# We make sure that the checksum of the file overriden is the same
# as the expected. If this test fails, it means that the overriden
# file should be updated to match any change/bug fix introduced in the core
checksums = [
  {
    package: "decidim-core",
    files: {
      # layouts
      "/app/views/layouts/decidim/_head_extra.html.erb" => "25642b423f3b3a1ac9c69bf558a6b791",
      "/app/views/layouts/decidim/mailer.html.erb" => "6a08103c75e5db737a38cd365428a177",
      # devise
      "/app/views/decidim/devise/sessions/new.html.erb" => "da0d18178c8dcead2774956e989527c5",
      # cells
      "/app/cells/decidim/tos_page/form.erb" => "8b96e48e92277db50f6e2bbef61d77e5"
    }
  },
  {
    package: "decidim-direct_verifications",
    files: {
      # devise
      "/app/views/devise/mailer/direct_invite.html.erb" => "094174f490539e4b21d530efce951c2f",
      "/app/views/devise/mailer/direct_invite.text.erb" => "a8bb5931b6c1b719a96de60dc7093d5f"
    }
  },
  {
    package: "decidim-assemblies",
    files: {
      # just to take into the account if some routes change
      "/lib/decidim/assemblies/engine.rb" => "e786f894c74012de408f1062113ce75a",
      "/lib/decidim/assemblies/admin_engine.rb" => "159b92a0968dccc3b522cc13fd00732d",
      "/app/models/decidim/assembly.rb" => "0a821e89a6f470d1cf370fa7eb474236"
    }
  },
  {
    package: "decidim-meetings",
    files: {
      "/app/controllers/decidim/meetings/meetings_controller.rb" => "4e30f2de3bc8bc41e4f52ba28ba1bb4d"
    }
  },
  {
    package: "decidim-direct_verifications",
    files: {
      # The only change for controllers is the full namespace for the parent class as it didn't resolved it well when it
      # was just ApplicationController
      "/app/controllers/decidim/direct_verifications/verification/admin/authorizations_controller.rb" => "5b713aa72da2ba5e4f0fefa840816004",
      "/app/controllers/decidim/direct_verifications/verification/admin/direct_verifications_controller.rb" => "dfe29d5353030989c07866d37b794157",
      "/app/controllers/decidim/direct_verifications/verification/admin/imports_controller.rb" => "43852a21a6aca14404c2959bb70bdb19",
      "/app/controllers/decidim/direct_verifications/verification/admin/stats_controller.rb" => "a0c4ae48b1372ea5d37aae0112c9c826",
      "/app/controllers/decidim/direct_verifications/verification/admin/user_authorizations_controller.rb" => "705d2ef9a0c33ad68899b28c4b1dc42d"
    }
  }
]

describe "Overriden files", type: :view do
  checksums.each do |item|
    spec = Gem::Specification.find_by_name(item[:package])

    item[:files].each do |file, signature|
      it "#{spec.gem_dir}#{file} matches checksum" do
        expect(md5("#{spec.gem_dir}#{file}")).to eq(signature)
      end
    end
  end

  private

  def md5(file)
    Digest::MD5.hexdigest(File.read(file))
  end
end
