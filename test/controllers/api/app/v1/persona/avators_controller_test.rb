require "test_helper"

class Api::V1::Persona::AvatarsControllerTest < ActionDispatch::IntegrationTest
  # FIXME: change to run only json files
  test "should get index" do
    get api_app_v1_persona_avatars_url # (format: :json)
    assert_select "h1", 'Api::V1::Persona::Avators#index'
    assert_select "p", 'Find me in app/views/api/v1/persona/avators/index.html.erb'
    assert_response :success
  end

  # test "shouldj not get index when html response" do
  #   get api_app_v1_persona_avatars_url(format: :html)
  #   assert_response :not_acceptable
  # end

  # FIXME: change to run only json files
  test "should get new" do
    get new_api_app_v1_persona_avatar_url
    assert_select "h1", 'Api::V1::Persona::Avators#new'
    assert_select "p", 'Find me in app/views/api/v1/persona/avators/new.html.erb'
    assert_response :success
  end

  # test "shouldj not get new when html response" do
  #   get new_api_app_v1_persona_avatar_url(format: :html)
  #   assert_response :not_acceptable
  # end

  # FIXME: change to run only json files
  test "should get show" do
    get api_app_v1_persona_avatar_url(1)
    assert_response :success
  end
end
