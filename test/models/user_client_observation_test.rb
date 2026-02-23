# typed: false
# == Schema Information
#
# Table name: user_client_observations
# Database name: principal
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  client_id  :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_user_client_observations_on_client_id              (client_id)
#  index_user_client_observations_on_user_id_and_client_id  (user_id,client_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (user_id => users.id)
#

# frozen_string_literal: true

require "test_helper"

class UserClientObservationTest < ActiveSupport::TestCase
  fixtures :user_client_observations

  test "fixture is valid" do
    assert_predicate user_client_observations(:one), :valid?
  end
end
