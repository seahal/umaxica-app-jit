# == Schema Information
#
# Table name: user_client_deletions
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
#  index_user_client_deletions_on_client_id              (client_id)
#  index_user_client_deletions_on_user_id_and_client_id  (user_id,client_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (user_id => users.id)
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
