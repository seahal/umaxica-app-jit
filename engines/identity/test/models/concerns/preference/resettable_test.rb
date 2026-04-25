# typed: false
# frozen_string_literal: true

require "test_helper"

module Preference
  class ResettableTest < ActiveSupport::TestCase
    class TestModel
      include ActiveModel::Model
      include Preference::Resettable

      attr_accessor :confirm_reset
    end

    test "has confirm_reset accessor" do
      model = TestModel.new
      model.confirm_reset = "1"

      assert_equal "1", model.confirm_reset
    end

    test "validation passes when confirm_reset is 1 on reset context" do
      model = TestModel.new(confirm_reset: "1")
      model.valid?(:reset)

      assert_empty model.errors
    end

    test "validation fails when confirm_reset is not 1 on reset context" do
      model = TestModel.new(confirm_reset: "0")
      model.valid?(:reset)

      assert_predicate model.errors[:confirm_reset], :any?
    end

    test "validation fails when confirm_reset is blank on reset context" do
      model = TestModel.new(confirm_reset: nil)
      model.valid?(:reset)

      assert_predicate model.errors[:confirm_reset], :any?
    end

    test "require_reset_confirmation sets confirm_reset value" do
      model = TestModel.new
      model.require_reset_confirmation("1")

      assert_equal "1", model.confirm_reset
    end

    test "require_reset_confirmation returns self for chaining" do
      model = TestModel.new

      result = model.require_reset_confirmation("1")

      assert_same model, result
    end
  end
end
