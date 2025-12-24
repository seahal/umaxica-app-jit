# == Schema Information
#
# Table name: user_occurrence_statuses
#
#  id         :string(255)      default("NONE"), not null, primary key
#  expires_at :datetime         not null
#
# Indexes
#
#  index_user_occurrence_statuses_on_expires_at  (expires_at)
#

require "test_helper"

class UserOccurrenceStatusTest < ActiveSupport::TestCase
  include OccurrenceStatusTestHelper

  test "expires_at default" do
    record = UserOccurrenceStatus.new(id: "EXPIRES_AT_TEST")

    assert_expires_at_default(record)
  end
end
