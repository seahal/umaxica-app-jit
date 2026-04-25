# typed: false
# frozen_string_literal: true

require "test_helper"

class ProsopiteInitializerTest < ActiveSupport::TestCase
  test "prosopite raises in test to fail fast on N+1" do
    assert_predicate Prosopite, :raise?
  end

  test "prosopite ignores internal rails metadata queries" do
    patterns = Prosopite.ignore_queries

    assert patterns.any? { |pattern| pattern.match?('SELECT * FROM "ar_internal_metadata"') }
    assert patterns.any? { |pattern| pattern.match?('SELECT * FROM "schema_migrations"') }
  end
end
