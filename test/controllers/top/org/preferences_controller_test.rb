require "test_helper"


class Top::Org::PreferencesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get top_org_preference_url

    assert_response :success
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should display i18n content in preferences page" do
    get top_org_preference_url

    assert_response :success
    assert_select "h1", text: I18n.t("top.org.preferences.title")
    # Verify that preference links are present (translations should exist)
    assert_select "a", minimum: 1
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "should render copyright in footer" do
    get top_org_preference_url

    assert_select "footer" do
      assert_select "small", text: /^©/
      assert_select "small", text: /#{brand_name}$/
    end
  end
  # rubocop:enable Minitest/MultipleAssertions
end
