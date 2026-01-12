# frozen_string_literal: true

require "test_helper"

require "ostruct"

class Sign::App::Configuration::EmailsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @email = OpenStruct.new(id: "1")
  end

  test "should get index" do
    get sign_app_configuration_emails_url(ri: "jp")
    assert_response :success
  end

  test "should get show" do
    get sign_app_configuration_email_url(@email, ri: "jp")
    assert_response :success
  end

  test "should get new" do
    get new_sign_app_configuration_email_url(ri: "jp")
    assert_response :success
  end

  test "should get create" do
    get sign_app_configuration_emails_url(ri: "jp")
    assert_response :success
  end

  test "should get edit" do
    get edit_sign_app_configuration_email_url(@email, ri: "jp")
    assert_response :success
  end

  test "should get update" do
    get sign_app_configuration_email_url(@email, ri: "jp")
    assert_response :success
  end

  test "should get destroy" do
    get sign_app_configuration_email_url(@email, ri: "jp")
    assert_response :success
  end
end
