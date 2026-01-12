# frozen_string_literal: true

require "test_helper"

require "ostruct"

class Sign::App::Configuration::TelephonesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @telephone = OpenStruct.new(id: "1")
  end

  test "should get index" do
    get sign_app_configuration_telephones_url(ri: "jp")
    assert_response :success
  end

  test "should get show" do
    get sign_app_configuration_telephone_url(@telephone, ri: "jp")
    assert_response :success
  end

  test "should get new" do
    get new_sign_app_configuration_telephone_url(ri: "jp")
    assert_response :success
  end

  test "should get create" do
    get sign_app_configuration_telephones_url(ri: "jp")
    assert_response :success
  end

  test "should get edit" do
    get edit_sign_app_configuration_telephone_url(@telephone, ri: "jp")
    assert_response :success
  end

  test "should get update" do
    get sign_app_configuration_telephone_url(@telephone, ri: "jp")
    assert_response :success
  end

  test "should get destroy" do
    get sign_app_configuration_telephone_url(@telephone, ri: "jp")
    assert_response :success
  end
end
