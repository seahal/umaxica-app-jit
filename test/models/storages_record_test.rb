require "test_helper"

class StoragesRecordTest < ActiveSupport::TestCase
  test "is abstract and inherits from ApplicationRecord" do
    assert StoragesRecord < ApplicationRecord
    assert StoragesRecord.abstract_class?
  end
end

