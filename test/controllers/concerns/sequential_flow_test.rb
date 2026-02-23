# typed: false
# frozen_string_literal: true

require "test_helper"

class SequentialFlowDummyController < ApplicationController
  include SequentialFlow

  flow :registration do
    step 1, actions: %i(new create)
    step 2, actions: %i(edit update)
    step 3, actions: %i(show destroy)
  end

  before_action :enforce_flow!

  def new
    render plain: "new"
  end

  def create
    advance_step!
    redirect_to "/edit"
  end

  def edit
    render plain: "edit"
  end

  def update
    advance_step!
    redirect_to "/show"
  end

  def show
    render plain: "show"
  end

  def destroy
    reset_flow!
    redirect_to "/new"
  end

  private

  def flow_initial_path
    "/new"
  end
end

class SequentialFlowConcernTest < ActionDispatch::IntegrationTest
  test "flow starts at initial step" do
    with_routing do |set|
      set.draw do
        get "/new", to: "sequential_flow_dummy#new"
        post "/create", to: "sequential_flow_dummy#create"
        get "/edit", to: "sequential_flow_dummy#edit"
        patch "/update", to: "sequential_flow_dummy#update"
        get "/show", to: "sequential_flow_dummy#show"
        delete "/destroy", to: "sequential_flow_dummy#destroy"
      end

      get "/new"
      assert_response :success
      assert_equal "new", response.body
    end
  end

  test "flow enforces step order" do
    with_routing do |set|
      set.draw do
        get "/new", to: "sequential_flow_dummy#new"
        post "/create", to: "sequential_flow_dummy#create"
        get "/edit", to: "sequential_flow_dummy#edit"
        patch "/update", to: "sequential_flow_dummy#update"
        get "/show", to: "sequential_flow_dummy#show"
        delete "/destroy", to: "sequential_flow_dummy#destroy"
      end

      # Try to access edit without completing step 1
      get "/edit"
      assert_redirected_to "/new"
      assert_equal I18n.t("sequential_flow.invalid_step"), flash[:alert]
    end
  end

  test "flow advances after successful create" do
    with_routing do |set|
      set.draw do
        get "/new", to: "sequential_flow_dummy#new"
        post "/create", to: "sequential_flow_dummy#create"
        get "/edit", to: "sequential_flow_dummy#edit"
      end

      post "/create"
      assert_redirected_to "/edit"

      # Now edit should be accessible
      get "/edit"
      assert_response :success
      assert_equal "edit", response.body
    end
  end

  test "flow advances through all steps" do
    with_routing do |set|
      set.draw do
        get "/new", to: "sequential_flow_dummy#new"
        post "/create", to: "sequential_flow_dummy#create"
        get "/edit", to: "sequential_flow_dummy#edit"
        patch "/update", to: "sequential_flow_dummy#update"
        get "/show", to: "sequential_flow_dummy#show"
      end

      # Step 1
      get "/new"
      assert_response :success

      post "/create"
      assert_redirected_to "/edit"

      # Step 2
      get "/edit"
      assert_response :success

      patch "/update"
      assert_redirected_to "/show"

      # Step 3
      get "/show"
      assert_response :success
    end
  end
end
