# typed: false
# frozen_string_literal: true

require "test_helper"

class BillingRecordTest < ActiveSupport::TestCase
  test "is abstract and inherits from ApplicationRecord" do
    assert_operator BillingRecord, :<, ApplicationRecord
    assert_predicate BillingRecord, :abstract_class?
  end

  test "is configured as a database-backed base class" do
    assert_respond_to BillingRecord, :connection_db_config
  end
end
