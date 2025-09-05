require "test_helper"

class BusinessesRecordTest < ActiveSupport::TestCase
  test "is abstract and inherits from ApplicationRecord" do
    assert BusinessesRecord < ApplicationRecord
    assert BusinessesRecord.abstract_class?
  end
end

