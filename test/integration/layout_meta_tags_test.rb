require "test_helper"

class LayoutMetaTagsTest < ActionDispatch::IntegrationTest
  def setup
    # Map of Namespace => [Host ENV Name, Path]
    @targets = {
      "Peak::Com" => [ "PEAK_CORPORATE_URL", "/" ],
      "Peak::App" => [ "PEAK_SERVICE_URL", "/" ],
      "Peak::Org" => [ "PEAK_STAFF_URL", "/" ],
      "Back::Com" => [ "CORE_CORPORATE_URL", "/" ],
      "Back::App" => [ "CORE_SERVICE_URL", "/" ],
      "Back::Org" => [ "CORE_STAFF_URL", "/" ],
      "Docs::Com" => [ "DOCS_CORPORATE_URL", "/" ],
      "Docs::App" => [ "DOCS_SERVICE_URL", "/" ],
      "Docs::Org" => [ "DOCS_STAFF_URL", "/" ],
      "News::Com" => [ "NEWS_CORPORATE_URL", "/" ],
      "News::App" => [ "NEWS_SERVICE_URL", "/" ],
      "News::Org" => [ "NEWS_STAFF_URL", "/" ],
      "Help::Com" => [ "HELP_CORPORATE_URL", "/" ],
      "Help::App" => [ "HELP_SERVICE_URL", "/" ],
      "Help::Org" => [ "HELP_STAFF_URL", "/" ],
      "Auth::App" => [ "AUTH_SERVICE_URL", "/" ],
      "Auth::Org" => [ "AUTH_STAFF_URL", "/" ]
    }
  end

  test "all layouts include turbo-refresh-scroll meta tag" do
    @targets.each do |name, (env_key, path)|
      host = ENV[env_key]
      next if host.blank?

      host! host
      get path

      if response.redirect?
        follow_redirect!
      end

      assert_response :success, "Failed to access #{path} for #{name} (#{host})"
      assert_select "meta[name='turbo-refresh-scroll'][content='preserve']", 1,
                    "Expected turbo-refresh-scroll meta tag in #{name} layout"
    end
  end

  test "all layouts include title tag" do
    @targets.each do |name, (env_key, path)|
      host = ENV[env_key]
      next if host.blank?

      host! host
      get path

      if response.redirect?
        follow_redirect!
      end

      assert_response :success, "Failed to access #{path} for #{name} (#{host})"
      assert_select "title", { count: 1 }, "Expected exactly one title tag in #{name} layout"
    end
  end
end
