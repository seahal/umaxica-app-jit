# frozen_string_literal: true

require "test_helper"

class StaffSessionTest < ActiveSupport::TestCase
  test "inherits from TokensRecord" do
    assert StaffSession < TokensRecord
  end

  test "belongs to staff" do
    association = StaffSession.reflect_on_association(:staff)
    assert_not_nil association
    assert_equal :belongs_to, association.macro
  end
end
