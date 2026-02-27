# typed: false
# frozen_string_literal: true

require "test_helper"

class NotificationRecordTest < ActiveSupport::TestCase
  test "is abstract and inherits from ApplicationRecord" do
    assert_operator NotificationRecord, :<, ApplicationRecord
    assert_predicate NotificationRecord, :abstract_class?
  end
end
