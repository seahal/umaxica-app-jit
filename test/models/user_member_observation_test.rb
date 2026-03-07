# typed: false
# == Schema Information
#
# Table name: user_member_observations
# Database name: principal
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  member_id  :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_user_member_observations_on_member_id              (member_id)
#  index_user_member_observations_on_user_id_and_member_id  (user_id,member_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (member_id => members.id)
#  fk_rails_...  (user_id => users.id)
#

# frozen_string_literal: true

require "test_helper"

class UserMemberObservationTest < ActiveSupport::TestCase
  fixtures :user_member_observations, :users, :user_statuses, :members, :member_statuses, :divisions,
           :division_statuses, :organizations, :organization_statuses

  test "fixture is valid" do
    assert_predicate user_member_observations(:one), :valid?
  end
end
