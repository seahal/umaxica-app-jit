# frozen_string_literal: true

require "test_helper"

class AccountableTest < ActiveSupport::TestCase
  class DummyAccountable < IdentitiesRecord
    self.table_name = "users"
    include Accountable
  end

  test "includes Accountable concern" do
    assert_includes DummyAccountable.included_modules, Accountable
  end

  test "is an ActiveSupport::Concern" do
    assert_includes Accountable.singleton_class.included_modules, ActiveSupport::Concern
  end

  test "has_one :account association" do
    dummy = DummyAccountable.new
    assert_respond_to dummy, :account

    reflection = DummyAccountable.reflect_on_association(:account)
    assert_not_nil reflection
    assert_equal :has_one, reflection.macro
    assert_equal "accountable", reflection.options[:as].to_s
    assert reflection.options[:touch]
    assert_equal :destroy, reflection.options[:dependent]
  end
end
