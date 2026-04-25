# typed: false
# frozen_string_literal: true

module Jit
  module Foundation
    require "test_helper"

    # This test verifies controller inheritance hierarchy
    # Important for refactoring (e.g., changing parent classes)
    class CoreControllerInheritanceTest < ActiveSupport::TestCase
      test "app controllers inherit from proper base class" do
        assert_equal Jit::Foundation::Base::App::ApplicationController, Jit::Foundation::Base::App::RootsController.superclass
        assert_equal Jit::Foundation::Base::App::ApplicationController, Jit::Foundation::Base::App::ContactsController.superclass
        assert_equal Jit::Foundation::Base::App::ApplicationController, Jit::Foundation::Base::App::ConfigurationsController.superclass
      end

      test "com controllers inherit from proper base class" do
        assert_equal Jit::Foundation::Base::Com::ApplicationController, Jit::Foundation::Base::Com::RootsController.superclass
        assert_equal Jit::Foundation::Base::Com::ApplicationController, Jit::Foundation::Base::Com::ContactsController.superclass
        assert_equal Jit::Foundation::Base::Com::ApplicationController, Jit::Foundation::Base::Com::ConfigurationsController.superclass
      end

      test "org controllers inherit from proper base class" do
        assert_equal Jit::Foundation::Base::Org::ApplicationController, Jit::Foundation::Base::Org::RootsController.superclass
        assert_equal Jit::Foundation::Base::Org::ApplicationController, Jit::Foundation::Base::Org::ContactsController.superclass
        assert_equal Jit::Foundation::Base::Org::ApplicationController, Jit::Foundation::Base::Org::ConfigurationsController.superclass
      end

      test "auth callbacks inherit from ApplicationController" do
        assert_equal Jit::Foundation::Base::App::ApplicationController, Jit::Foundation::Base::App::Auth::CallbacksController.superclass
        assert_equal Jit::Foundation::Base::Com::ApplicationController, Jit::Foundation::Base::Com::Auth::CallbacksController.superclass
        assert_equal Jit::Foundation::Base::Org::ApplicationController, Jit::Foundation::Base::Org::Auth::CallbacksController.superclass
      end

      test "edge controllers inherit from ApplicationController" do
        assert_equal Jit::Foundation::Base::App::ApplicationController, Jit::Foundation::Base::App::Edge::V0::HealthsController.superclass
        assert_equal Jit::Foundation::Base::App::ApplicationController, Jit::Foundation::Base::App::Edge::V0::MessagesController.superclass
        assert_equal Jit::Foundation::Base::Com::ApplicationController, Jit::Foundation::Base::Com::Edge::V0::HealthsController.superclass
      end

      test "web controllers inherit from ApplicationController" do
        assert_equal Jit::Foundation::Base::App::ApplicationController, Jit::Foundation::Base::App::Web::V0::CookiesController.superclass
        assert_equal Jit::Foundation::Base::App::ApplicationController, Jit::Foundation::Base::App::Web::V0::ThemesController.superclass
      end

      test "emergency controllers inherit from org application controller" do
        assert_equal Jit::Foundation::Base::Org::ApplicationController, Jit::Foundation::Base::Org::Emergency::App::OutagesController.superclass
        assert_equal Jit::Foundation::Base::Org::ApplicationController, Jit::Foundation::Base::Org::Emergency::Com::OutagesController.superclass
        assert_equal Jit::Foundation::Base::Org::ApplicationController, Jit::Foundation::Base::Org::Emergency::Org::OutagesController.superclass
        assert_equal Jit::Foundation::Base::Org::ApplicationController, Jit::Foundation::Base::Org::Emergency::Org::TokensController.superclass
      end

      test "docs controllers inherit from org application controller" do
        assert_equal Jit::Foundation::Base::Org::ApplicationController, Jit::Foundation::Base::Org::Jit::Distributor::Docs::Com::PostsController.superclass
        assert_equal Jit::Foundation::Base::Org::ApplicationController, Jit::Foundation::Base::Org::Jit::Distributor::Docs::Org::PostsController.superclass
        assert_equal Jit::Foundation::Base::Org::ApplicationController, Jit::Foundation::Base::Org::Jit::Distributor::Docs::App::PostsController.superclass
      end

      test "base application controllers inherit from ActionController::Base" do
        assert_equal ActionController::Base, Jit::Foundation::Base::App::ApplicationController.superclass
        assert_equal ActionController::Base, Jit::Foundation::Base::Com::ApplicationController.superclass
        assert_equal ActionController::Base, Jit::Foundation::Base::Org::ApplicationController.superclass
      end
    end
  end
end
