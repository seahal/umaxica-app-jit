# frozen_string_literal: true

require "test_helper"

class AuthnConcernTest < ActionDispatch::IntegrationTest
  class TestController < ApplicationController
    include Authn

    def test_action
      head :ok
    end

    def test_request
      @request
    end
  end

  setup do
    @controller = TestController.new
    @controller.instance_variable_set(:@request, ActionDispatch::TestRequest.create)
    Rails.application.routes.disable_clear_and_finalize = true
    Rails.application.routes.draw do
      get "test" => "authn_concern_test/test#test_action"
    end
  end

  teardown do
    Rails.application.reload_routes!
  end

  test "JWT_ALGORITHM constant is ES256" do
    assert_equal "ES256", Authn::JWT_ALGORITHM
  end

  test "ACCESS_TOKEN_EXPIRY constant is 15 minutes" do
    assert_equal 15.minutes, Authn::ACCESS_TOKEN_EXPIRY
  end

  test "generate_access_token raises error if user_or_staff is nil" do
    assert_raises(RuntimeError) do
      @controller.send(:generate_access_token, nil)
    end
  end

  test "generate_access_token raises error if user_or_staff does not respond to id" do
    object_without_id = Object.new
    assert_raises(RuntimeError) do
      @controller.send(:generate_access_token, object_without_id)
    end
  end

  test "generate_access_token raises error if user_or_staff id is blank" do
    user_with_blank_id = OpenStruct.new(id: nil)
    assert_raises(RuntimeError) do
      @controller.send(:generate_access_token, user_with_blank_id)
    end
  end

  test "verify_access_token raises error if token is blank" do
    assert_raises(JWT::VerificationError) do
      @controller.send(:verify_access_token, "")
    end
  end

  test "verify_access_token raises error if token is nil" do
    assert_raises(JWT::VerificationError) do
      @controller.send(:verify_access_token, nil)
    end
  end

  test "logged_in? returns false when access_token cookie is blank" do
    get test_url
    assert_equal false, @controller.logged_in?
  end

  test "am_i_user? raises NotImplementedError" do
    assert_raises(RuntimeError) do
      @controller.send(:am_i_user?)
    end
  end

  test "am_i_staff? raises NotImplementedError" do
    assert_raises(RuntimeError) do
      @controller.send(:am_i_staff?)
    end
  end

  test "am_i_owner? raises NotImplementedError" do
    assert_raises(RuntimeError) do
      @controller.send(:am_i_owner?)
    end
  end

  private

  def test_url
    "http://test.localhost/test"
  end
end
