require "test_helper"

class Api::V1::Persona::AvatarsControllerTest < ActionDispatch::IntegrationTest
  # FIXME: change to run only json files
  test "should get index" do
    get api_app_v1_persona_avatars_url # (format: :json)
    assert_response :success
  end

  # test "shouldj not get index when html response" do
  #   get api_app_v1_persona_avatars_url(format: :html)
  #   assert_response :not_acceptable
  # end

  # FIXME: change to run only json files
  test "should get new" do
    get new_api_app_v1_persona_avatar_url
    assert_response :success
  end

  # test "shouldj not get new when html response" do
  #   get new_api_app_v1_persona_avatar_url(format: :html)
  #   assert_response :not_acceptable
  # end

  # test "should get show" do
  #   get api_v1_persona_avators_show_url
  #   assert_response :success
  # end
end
