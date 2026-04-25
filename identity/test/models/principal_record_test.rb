# typed: false
# frozen_string_literal: true

require "test_helper"

class PrincipalRecordTest < ActiveSupport::TestCase
  test "is abstract class" do
    assert_predicate PrincipalRecord, :abstract_class?
  end

  test "inherits from ApplicationRecord" do
    assert_operator PrincipalRecord, :<, ApplicationRecord
  end
end
