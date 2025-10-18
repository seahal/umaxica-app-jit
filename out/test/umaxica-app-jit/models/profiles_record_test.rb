require "test_helper"

class ProfilesRecordTest < ActiveSupport::TestCase
  test "is abstract and inherits from ApplicationRecord" do
    assert ProfilesRecord < ApplicationRecord
    assert ProfilesRecord.abstract_class?
  end
end
