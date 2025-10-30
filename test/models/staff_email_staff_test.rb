# frozen_string_literal: true

require "test_helper"

class StaffEmailStaffTest < ActiveSupport::TestCase
  test "inherits from TokensRecord" do
    assert_operator StaffEmailStaff, :<, TokensRecord
  end

  test "belongs to email" do
    association = StaffEmailStaff.reflect_on_association(:email)

    assert_not_nil association
    assert_equal :belongs_to, association.macro
    assert_predicate association.options[:inverse_of], :present?
  end

  test "belongs to staff" do
    association = StaffEmailStaff.reflect_on_association(:staff)

    assert_not_nil association
    assert_equal :belongs_to, association.macro
    assert_predicate association.options[:inverse_of], :present?
  end
end
