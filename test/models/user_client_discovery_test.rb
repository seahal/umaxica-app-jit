# == Schema Information
#
# Table name: user_client_discoveries
#
#  id         :uuid             not null, primary key
#  user_id    :uuid             not null
#  client_id  :uuid             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_user_client_discoveries_on_client_id              (client_id)
#  index_user_client_discoveries_on_user_id                (user_id)
#  index_user_client_discoveries_on_user_id_and_client_id  (user_id,client_id) UNIQUE
#

# frozen_string_literal: true

require "test_helper"

class UserClientDiscoveryTest < ActiveSupport::TestCase
  test "fixture is valid" do
    assert_predicate user_client_discoveries(:one), :valid?
  end
end
