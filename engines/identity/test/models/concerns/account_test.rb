# typed: false
# frozen_string_literal: true

require "test_helper"

# Test classes for Account concern inclusion
# Defined at the top level to ensure they have proper names for validates_reference_table
class TestAccountModelWithPublicId < ApplicationRecord
  self.table_name = "members"
  include Account
end

class TestAccountModelInclusion < ApplicationRecord
  self.table_name = "members"
  include Account
end

module Account
  class AccountTest < ActiveSupport::TestCase
    test "is a valid concern module" do
      assert_kind_of Module, Account
      assert_includes Account.singleton_class.included_modules, ActiveSupport::Concern
    end

    test "includes PublicId concern" do
      # Account includes PublicId at the module level
      # Check that PublicId is available when Account is included
      assert_includes TestAccountModelWithPublicId.ancestors, PublicId
    end

    test "can be included in a model class" do
      assert_includes TestAccountModelInclusion.ancestors, Account
      assert_includes TestAccountModelInclusion.ancestors, PublicId
    end
  end
end
