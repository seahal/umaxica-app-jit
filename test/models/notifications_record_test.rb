# frozen_string_literal: true

require "test_helper"

class NotificationsRecordTest < ActiveSupport::TestCase
  test "is abstract and inherits from ApplicationRecord" do
    assert_operator NotificationsRecord, :<, ApplicationRecord
    assert_predicate NotificationsRecord, :abstract_class?
  end
end
