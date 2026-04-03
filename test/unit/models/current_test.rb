# typed: false
# frozen_string_literal: true

require "test_helper"

class CurrentTest < ActiveSupport::TestCase
  setup do
    Current.reset
  end

  teardown do
    Current.reset
  end

  test "surface defaults to :com" do
    assert_equal :com, Current.surface
  end

  test "realm defaults to :www" do
    assert_equal :www, Current.realm
  end

  test "request_id defaults to empty string" do
    assert_equal "", Current.request_id
  end

  test "boundary_key combines realm and surface" do
    Current.realm = :sign
    Current.surface = :app

    assert_equal "sign:app", Current.boundary_key
  end

  test "boundary_key uses defaults when not set" do
    assert_equal "www:com", Current.boundary_key
  end

  test "boundary_key is frozen" do
    assert_predicate Current.boundary_key, :frozen?
  end
end
