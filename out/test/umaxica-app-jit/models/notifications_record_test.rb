require "test_helper"

class NotificationsRecordTest < ActiveSupport::TestCase
  test "is abstract and inherits from ApplicationRecord" do
    assert NotificationsRecord < ApplicationRecord
    assert NotificationsRecord.abstract_class?
  end
end
