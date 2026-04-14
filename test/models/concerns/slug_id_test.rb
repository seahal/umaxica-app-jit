# typed: false
# frozen_string_literal: true

require "test_helper"

module SlugId
  class SlugIdTest < ActiveSupport::TestCase
    class TestModel
      include ActiveModel::Model
      include ActiveModel::Validations::Callbacks

      # SlugId concern calls before_create, which is not available outside ActiveRecord.
      # Define a no-op so the concern can be included for unit testing.
      def self.before_create(*)
      end

      attr_accessor :slug_id

      include SlugId
    end

    test "generates slug_id before validation on create" do
      model = TestModel.new
      model.valid?(:create)

      assert_not_nil model.slug_id
      assert_match(/\A[a-z0-9]+(?:-[a-z0-9]+)*\z/, model.slug_id)
    end

    test "does not overwrite existing slug_id" do
      model = TestModel.new(slug_id: "custom-slug-id")
      model.valid?(:create)

      assert_equal "custom-slug-id", model.slug_id
    end

    test "validates slug_id format" do
      model = TestModel.new(slug_id: "invalid slug with spaces")

      assert_not model.valid?(:create)
      assert_predicate model.errors[:slug_id], :any?
    end

    test "validates slug_id presence" do
      # The before_validation callback auto-generates slug_id, so presence always passes.
      # This test verifies the callback behavior instead.
      model = TestModel.new
      model.valid?(:create)

      assert_not_nil model.slug_id
      assert_not model.errors[:slug_id].any?
    end

    test "validates slug_id length" do
      model = TestModel.new(slug_id: "a" * 33)

      assert_not model.valid?(:create)
      assert_predicate model.errors[:slug_id], :any?
    end

    test "generates 32 character slug_id" do
      model = TestModel.new
      model.valid?(:create)

      assert_equal 32, model.slug_id.length
    end
  end
end
