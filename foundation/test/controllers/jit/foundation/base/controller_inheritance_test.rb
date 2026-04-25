# typed: false
# frozen_string_literal: true

    require "test_helper"

    # This test verifies controller inheritance hierarchy
    # Important for refactoring (e.g., changing parent classes)
    class CoreControllerInheritanceTest < ActiveSupport::TestCase
      test "app controllers inherit from proper base class" do
        assert_equal Base::App::ApplicationController, Base::App::RootsController.superclass
        assert_equal Base::App::ApplicationController, Base::App::ContactsController.superclass
        assert_equal Base::App::ApplicationController, Base::App::ConfigurationsController.superclass
      end

      test "com controllers inherit from proper base class" do
        assert_equal Base::Com::ApplicationController, Base::Com::RootsController.superclass
        assert_equal Base::Com::ApplicationController, Base::Com::ContactsController.superclass
        assert_equal Base::Com::ApplicationController, Base::Com::ConfigurationsController.superclass
      end

      test "org controllers inherit from proper base class" do
        assert_equal Base::Org::ApplicationController, Base::Org::RootsController.superclass
        assert_equal Base::Org::ApplicationController, Base::Org::ContactsController.superclass
        assert_equal Base::Org::ApplicationController, Base::Org::ConfigurationsController.superclass
      end

      test "auth callbacks inherit from ApplicationController" do
        assert_equal Base::App::ApplicationController, Base::App::Auth::CallbacksController.superclass
        assert_equal Base::Com::ApplicationController, Base::Com::Auth::CallbacksController.superclass
        assert_equal Base::Org::ApplicationController, Base::Org::Auth::CallbacksController.superclass
      end

      test "edge controllers inherit from ApplicationController" do
        assert_equal Base::App::ApplicationController, Base::App::Edge::V0::HealthsController.superclass
        assert_equal Base::App::ApplicationController, Base::App::Edge::V0::MessagesController.superclass
        assert_equal Base::Com::ApplicationController, Base::Com::Edge::V0::HealthsController.superclass
      end

      test "web controllers inherit from ApplicationController" do
        assert_equal Base::App::ApplicationController, Base::App::Web::V0::CookiesController.superclass
        assert_equal Base::App::ApplicationController, Base::App::Web::V0::ThemesController.superclass
      end

      test "emergency controllers inherit from org application controller" do
        assert_equal Base::Org::ApplicationController, Base::Org::Emergency::App::OutagesController.superclass
        assert_equal Base::Org::ApplicationController, Base::Org::Emergency::Com::OutagesController.superclass
        assert_equal Base::Org::ApplicationController, Base::Org::Emergency::Org::OutagesController.superclass
        assert_equal Base::Org::ApplicationController, Base::Org::Emergency::Org::TokensController.superclass
      end

      test "docs controllers inherit from org application controller" do
        assert_equal Base::Org::ApplicationController, Base::OrgDocs::Com::PostsController.superclass
        assert_equal Base::Org::ApplicationController, Base::OrgDocs::Org::PostsController.superclass
        assert_equal Base::Org::ApplicationController, Base::OrgDocs::App::PostsController.superclass
      end

      test "base application controllers inherit from ActionController::Base" do
        assert_equal ActionController::Base, Base::App::ApplicationController.superclass
        assert_equal ActionController::Base, Base::Com::ApplicationController.superclass
        assert_equal ActionController::Base, Base::Org::ApplicationController.superclass
      end
    end
  end
end
