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
      "/app/views/layouts/decidim/_head_extra.html.erb" => "1b8237357754cf519f4e418135f78440",
      "/app/views/layouts/decidim/mailer.html.erb" => "0c7804de08649c8d3c55c117005e51c9",
      # devise
      "/app/views/decidim/devise/sessions/new.html.erb" => "9d090fc9e565ded80a9330d4e36e495c",
      # cells
      "/app/cells/decidim/tos_page/form.erb" => "2518b45c702590a44e1df5b2eb13d937"
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
      "/lib/decidim/assemblies/engine.rb" => "9d08692b06cf403b6b788c728733f36e",
      "/lib/decidim/assemblies/admin_engine.rb" => "94c7e7db6aa85d2ea196e254a68e4626",
      "/app/models/decidim/assembly.rb" => "61c375d6091ac84b3ac04ab2b72f747c",
      "/app/views/decidim/assemblies/_filter_by_type.html.erb" => "c6ddcc8dd42702031f8027bb56b69687",
      "/app/views/decidim/assemblies/assemblies/_parent_assemblies.html.erb" => "fd026d4ee40dd1d5ebf8ad9ec5d0dbb4"
    }
  },
  {
    package: "decidim-meetings",
    files: {
      "/app/controllers/decidim/meetings/meetings_controller.rb" => "c4b88c68ea8b5653c6f1e35cd2646011"
    }
  } # ,
  # {
  #   package: "decidim-direct_verifications",
  #   files: {
  #     # The only change for controllers is the full namespace for the parent class as it didn't resolved it well when it
  #     # was just ApplicationController
  #     "/app/controllers/decidim/direct_verifications/verification/admin/authorizations_controller.rb" => "5b713aa72da2ba5e4f0fefa840816004",
  #     "/app/controllers/decidim/direct_verifications/verification/admin/direct_verifications_controller.rb" => "4f9cef25f72bb5ce88480850bd3f162a",
  #     "/app/controllers/decidim/direct_verifications/verification/admin/imports_controller.rb" => "477a63f3c749de204ccdc0987cd6b20d",
  #     "/app/controllers/decidim/direct_verifications/verification/admin/stats_controller.rb" => "a0c4ae48b1372ea5d37aae0112c9c826",
  #     "/app/controllers/decidim/direct_verifications/verification/admin/user_authorizations_controller.rb" => "c0f3387a8b76ecdf238e12e6c03daf3e"
  #   }
  # }
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
