# == Schema Information
#
# Table name: user_occurrences
#
#  id         :uuid             not null, primary key
#  public_id  :string(21)       default(""), not null
#  body       :string(36)       default(""), not null
#  status_id  :string(255)      default("NONE"), not null
#  memo       :string(1024)     default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  expires_at :datetime         not null
#
# Indexes
#
#  index_user_occurrences_on_body        (body) UNIQUE
#  index_user_occurrences_on_expires_at  (expires_at)
#  index_user_occurrences_on_public_id   (public_id) UNIQUE
#  index_user_occurrences_on_status_id   (status_id)
#

require "test_helper"

class UserOccurrenceTest < ActiveSupport::TestCase
  include OccurrenceTestHelper

  test "expires_at default" do
    record = build_occurrence(UserOccurrence, body: "user-occur-1", public_id: "Y" * 21)

    assert_expires_at_default(record)
  end
end
