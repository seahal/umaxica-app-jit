# frozen_string_literal: true

# == Schema Information
#
# Table name: user_occurrences
# Database name: occurrence
#
#  id         :bigint           not null, primary key
#  body       :string           default(""), not null
#  expires_at :datetime         not null
#  memo       :string           default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  public_id  :string(21)       default(""), not null
#  status_id  :string           default("NONE"), not null
#
# Indexes
#
#  index_user_occurrences_on_body        (body) UNIQUE
#  index_user_occurrences_on_expires_at  (expires_at)
#  index_user_occurrences_on_public_id   (public_id) UNIQUE
#  index_user_occurrences_on_status_id   (status_id)
#
# Foreign Keys
#
#  fk_rails_...  (status_id => user_occurrence_statuses.id)
#

require "test_helper"

class UserOccurrenceTest < ActiveSupport::TestCase
  test "expires_at default" do
    record = build_occurrence(UserOccurrence, body: "user-occur-1", public_id: "Y" * 21)

    assert_expires_at_default(record)
  end
end
