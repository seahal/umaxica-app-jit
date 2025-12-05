require "test_helper"

class LayoutMetaTagsTest < ActionDispatch::IntegrationTest
  test "all layouts include turbo-refresh-scroll meta tag" do
    # Map of Namespace => [Host ENV Name, Path]
    targets = {
      "Apex::Com" => [ "APEX_CORPORATE_URL", "/" ],
      "Apex::App" => [ "APEX_SERVICE_URL", "/" ],
      "Apex::Org" => [ "APEX_STAFF_URL", "/" ],
      "Back::Com" => [ "BACK_CORPORATE_URL", "/" ],
      "Back::App" => [ "BACK_SERVICE_URL", "/" ],
      "Back::Org" => [ "BACK_STAFF_URL", "/" ],
      "Docs::Com" => [ "DOCS_CORPORATE_URL", "/" ],
      "Docs::App" => [ "DOCS_SERVICE_URL", "/" ],
      "Docs::Org" => [ "DOCS_STAFF_URL", "/" ],
      "News::Com" => [ "NEWS_CORPORATE_URL", "/" ],
      "News::App" => [ "NEWS_SERVICE_URL", "/" ],
      "News::Org" => [ "NEWS_STAFF_URL", "/" ],
      "Help::Com" => [ "HELP_CORPORATE_URL", "/" ],
      "Help::App" => [ "HELP_SERVICE_URL", "/" ],
      "Help::Org" => [ "HELP_STAFF_URL", "/" ],
      "Sign::App" => [ "SIGN_SERVICE_URL", "/" ],
      "Sign::Org" => [ "SIGN_STAFF_URL", "/" ]
    }

    targets.each do |name, (env_key, path)|
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
end
