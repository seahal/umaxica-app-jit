# typed: false
# frozen_string_literal: true

require "test_helper"

module CategoryTag
  class CategoryTagTest < ActiveSupport::TestCase
    test "is a valid concern module" do
      assert_kind_of Module, CategoryTag
      assert_includes CategoryTag.singleton_class.included_modules, ActiveSupport::Concern
    end

    test "can be included in a model" do
      model_class =
        Class.new do
          include CategoryTag
        end

      assert_includes model_class.ancestors, CategoryTag
    end
  end
end
