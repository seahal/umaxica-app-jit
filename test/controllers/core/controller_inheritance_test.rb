# typed: false
# frozen_string_literal: true

require "test_helper"

# This test verifies controller inheritance hierarchy
# Important for refactoring (e.g., changing parent classes)
class CoreControllerInheritanceTest < ActiveSupport::TestCase
  test "app controllers inherit from proper base class" do
    assert_equal Core::App::ApplicationController, Core::App::RootsController.superclass
    assert_equal Core::App::ApplicationController, Core::App::ContactsController.superclass
    assert_equal Core::App::ApplicationController, Core::App::ConfigurationsController.superclass
  end

  test "com controllers inherit from proper base class" do
    assert_equal Core::Com::ApplicationController, Core::Com::RootsController.superclass
    assert_equal Core::Com::ApplicationController, Core::Com::ContactsController.superclass
    assert_equal Core::Com::ApplicationController, Core::Com::ConfigurationsController.superclass
  end

  test "org controllers inherit from proper base class" do
    assert_equal Core::Org::ApplicationController, Core::Org::RootsController.superclass
    assert_equal Core::Org::ApplicationController, Core::Org::ContactsController.superclass
    assert_equal Core::Org::ApplicationController, Core::Org::ConfigurationsController.superclass
  end

  test "auth callbacks inherit from ApplicationController" do
    assert_equal Core::App::ApplicationController, Core::App::Auth::CallbacksController.superclass
    assert_equal Core::Com::ApplicationController, Core::Com::Auth::CallbacksController.superclass
    assert_equal Core::Org::ApplicationController, Core::Org::Auth::CallbacksController.superclass
  end

  test "edge controllers inherit from ApplicationController" do
    assert_equal Core::App::ApplicationController, Core::App::Edge::V0::HealthsController.superclass
    assert_equal Core::App::ApplicationController, Core::App::Edge::V0::MessagesController.superclass
    assert_equal Core::Com::ApplicationController, Core::Com::Edge::V0::HealthsController.superclass
  end

  test "web controllers inherit from ApplicationController" do
    assert_equal Core::App::ApplicationController, Core::App::Web::V0::CookiesController.superclass
    assert_equal Core::App::ApplicationController, Core::App::Web::V0::ThemesController.superclass
  end

  test "emergency controllers inherit from org application controller" do
    assert_equal Core::Org::ApplicationController, Core::Org::Emergency::App::OutagesController.superclass
    assert_equal Core::Org::ApplicationController, Core::Org::Emergency::Com::OutagesController.superclass
    assert_equal Core::Org::ApplicationController, Core::Org::Emergency::Org::OutagesController.superclass
    assert_equal Core::Org::ApplicationController, Core::Org::Emergency::Org::TokensController.superclass
  end

  test "docs controllers inherit from org application controller" do
    assert_equal Core::Org::ApplicationController, Core::Org::Docs::Com::PostsController.superclass
    assert_equal Core::Org::ApplicationController, Core::Org::Docs::Org::PostsController.superclass
    assert_equal Core::Org::ApplicationController, Core::Org::Docs::App::PostsController.superclass
  end

  test "base application controllers inherit from ActionController::Base" do
    assert_equal ActionController::Base, Core::App::ApplicationController.superclass
    assert_equal ActionController::Base, Core::Com::ApplicationController.superclass
    assert_equal ActionController::Base, Core::Org::ApplicationController.superclass
  end
end
