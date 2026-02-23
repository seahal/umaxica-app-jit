# typed: false
# frozen_string_literal: true

require "test_helper"

class IdentifierRecordTest < ActiveSupport::TestCase
  test "is abstract and inherits from ApplicationRecord" do
    assert_operator PrincipalRecord, :<, ApplicationRecord
    assert_predicate PrincipalRecord, :abstract_class?
  end
end
