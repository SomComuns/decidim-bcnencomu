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
      "/app/views/layouts/decidim/mailer.html.erb" => "6a08103c75e5db737a38cd365428a177"
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
