# == Schema Information
#
# Table name: user_client_deletions
#
#  id         :uuid             not null, primary key
#  user_id    :uuid             not null
#  client_id  :uuid             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_user_client_deletions_on_client_id              (client_id)
#  index_user_client_deletions_on_user_id                (user_id)
#  index_user_client_deletions_on_user_id_and_client_id  (user_id,client_id) UNIQUE
#

# frozen_string_literal: true

require "test_helper"

class UserClientDeletionTest < ActiveSupport::TestCase
  test "fixture is valid" do
    # Fixture accessor might be broken, finding by user and client
    user = User.find_by!(public_id: "one_id")
    client = Client.find_by!(public_id: "client_one")
    deletion = UserClientDeletion.find_by!(user: user, client: client)
    assert_predicate deletion, :valid?
  end
end
