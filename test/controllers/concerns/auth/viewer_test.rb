# frozen_string_literal: true

require "test_helper"

class TestAuthViewerController < ApplicationController
  include Auth::Viewer
end

module Auth
  class ViewerTest < ActionDispatch::IntegrationTest
    setup do
      @controller = TestAuthViewerController.new
    end

    test "Viewer concern includes Auth::Base" do
      assert_includes TestAuthViewerController.ancestors, Auth::Base
    end

    test "Viewer concern includes Authentication::Viewer" do
      assert_includes TestAuthViewerController.ancestors, Authentication::Viewer
    end

    test "Viewer concern includes Authorization::Viewer" do
      assert_includes TestAuthViewerController.ancestors, Authorization::Viewer
    end

    test "Viewer concern includes Verification::Viewer" do
      assert_includes TestAuthViewerController.ancestors, Verification::Viewer
    end

    test "constants are exported from Auth::Base" do
      assert_equal Auth::Base::ACCESS_COOKIE_KEY, Auth::Viewer::ACCESS_COOKIE_KEY
      assert_equal Auth::Base::REFRESH_COOKIE_KEY, Auth::Viewer::REFRESH_COOKIE_KEY
      assert_equal Auth::Base::DEVICE_COOKIE_KEY, Auth::Viewer::DEVICE_COOKIE_KEY
      assert_equal Auth::Base::ACCESS_TOKEN_TTL, Auth::Viewer::ACCESS_TOKEN_TTL
      assert_equal Auth::Base::REFRESH_TOKEN_TTL, Auth::Viewer::REFRESH_TOKEN_TTL
      assert_equal Auth::Base::AUDIT_EVENTS, Auth::Viewer::AUDIT_EVENTS
    end

    test "current_viewer is aliased to current_resource" do
      assert_respond_to @controller, :current_viewer
    end

    test "authenticate_viewer! is aliased to authenticate!" do
      assert_respond_to @controller, :authenticate_viewer!
    end

    test "logged_in_viewer? is aliased to logged_in?" do
      assert_respond_to @controller, :logged_in_viewer?
    end

    test "active_viewer? returns false" do
      assert_not @controller.active_viewer?
    end

    test "am_i_user? returns false for viewer" do
      assert_not @controller.am_i_user?
    end

    test "am_i_staff? returns false for viewer" do
      assert_not @controller.am_i_staff?
    end

    test "am_i_owner? returns false for viewer" do
      assert_not @controller.am_i_owner?
    end

    test "resource_type returns viewer" do
      assert_equal "viewer", @controller.send(:resource_type)
    end

    test "resource_foreign_key returns viewer_id" do
      assert_equal :viewer_id, @controller.send(:resource_foreign_key)
    end

    test "test_header_key returns X-TEST-CURRENT-VIEWER" do
      assert_equal "X-TEST-CURRENT-VIEWER", @controller.send(:test_header_key)
    end

    test "transparent_refresh_access_token returns nil" do
      assert_nil @controller.transparent_refresh_access_token
    end
  end
end
