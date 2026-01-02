# frozen_string_literal: true

require "test_helper"

class IdentifierRecordTest < ActiveSupport::TestCase
  test "is abstract and inherits from ApplicationRecord" do
    assert_operator IdentitiesRecord, :<, ApplicationRecord
    assert_predicate IdentitiesRecord, :abstract_class?
  end
end
