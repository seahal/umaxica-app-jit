# typed: false
# frozen_string_literal: true

require "test_helper"

class PreferenceGlobalDummyController < ApplicationController
  include ::Preference::Global

  before_action :set_region

  def index
    render plain: "ok"
  end
end

class PreferenceGlobalConcernTest < ActionDispatch::IntegrationTest
  test "set_region redirects to current path with ri when missing" do
    with_routing do |set|
      set.draw do
        get "/preference_global_dummy", to: "preference_global_dummy#index"
      end

      host! "com.localhost"

      get "/preference_global_dummy", params: { foo: "bar" }

      assert_response :redirect
      assert_match(%r{\Ahttp://com\.localhost/preference_global_dummy\?}, response.location)
      assert_match(/foo=bar/, response.location)
      assert_match(/ri=jp/, response.location)
    end
  end

  test "set_region keeps request when ri is present" do
    with_routing do |set|
      set.draw do
        get "/preference_global_dummy", to: "preference_global_dummy#index"
      end

      host! "com.localhost"

      get "/preference_global_dummy", params: { ri: "us" }

      assert_response :success
      assert_equal "ok", response.body
    end
  end
end
