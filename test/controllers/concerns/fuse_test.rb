# frozen_string_literal: true

require "test_helper"

class TestFuseController < ApplicationController
  include Fuse

  def index
    render plain: "ok"
  end

  def create
    render plain: "created"
  end
end

class FuseTest < ActiveSupport::TestCase
  test "Fuse is a module" do
    assert_kind_of Module, Fuse
  end

  test "Fuse can be included in a controller" do
    assert_includes TestFuseController.ancestors, Fuse
  end

  test "controller has check_fuse! method" do
    controller = TestFuseController.new

    assert_includes controller.private_methods, :check_fuse!
  end

  test "controller has handle_fuse_violation method" do
    controller = TestFuseController.new

    assert_includes controller.private_methods, :handle_fuse_violation
  end

  test "controller has current_actor_type method" do
    controller = TestFuseController.new

    assert_includes controller.private_methods, :current_actor_type
  end

  test "current_actor_type returns :guest when no Current context" do
    controller = TestFuseController.new

    assert_equal :guest, controller.send(:current_actor_type)
  end
end
