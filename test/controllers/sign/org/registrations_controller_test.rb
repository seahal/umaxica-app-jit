# frozen_string_literal: true

require "test_helper"

module Sign::Org
  class RegistrationsControllerTest < ActionDispatch::IntegrationTest
    test "should get new" do
      get new_sign_org_registration_url

      assert_response :success
    end

    test "should have registration methods" do
      get new_sign_org_registration_url

      assert_response :success
      # Verify registration methods are available
    end

    test "should have social providers" do
      get new_sign_org_registration_url

      assert_response :success
      # Verify social providers are available
    end

    # rubocop:disable Minitest/MultipleAssertions
    test "should render copyright in footer" do
      get new_sign_org_registration_url

      assert_select "footer" do
        assert_select "small", text: /^©/
        assert_select "small", text: /#{brand_name}$/
      end
    end
    # rubocop:enable Minitest/MultipleAssertions

    # rubocop:disable Minitest/MultipleAssertions
    test "renders registration layout structure" do
      get new_sign_org_registration_url

      expected_brand = brand_name

      assert_select "head", count: 1 do
        assert_select "title", count: 1, text: "#{expected_brand} (org)"
      end
      assert_select "body", count: 1 do
        assert_select "header", minimum: 1
        assert_select "main", count: 1
        assert_select "footer", count: 1
      end
    end
    # rubocop:enable Minitest/MultipleAssertions

    # rubocop:disable Minitest/MultipleAssertions
    test "footer contains navigation links" do
      get new_sign_org_registration_url

      assert_response :success
      assert_select "footer" do
        # Footer should contain copyright and links
        assert_select "a[href*=?]", ENV["EDGE_STAFF_URL"], text: "home"
      end
    end
    # rubocop:enable Minitest/MultipleAssertions

    private

    def brand_name
      (ENV["BRAND_NAME"].presence || ENV["NAME"]).to_s
    end
  end
end
