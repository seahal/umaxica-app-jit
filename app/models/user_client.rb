# == Schema Information
#
# Table name: user_clients
#
#  id         :uuid             not null, primary key
#  user_id    :uuid             not null
#  client_id  :uuid             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_user_clients_on_client_id              (client_id)
#  index_user_clients_on_user_id_and_client_id  (user_id,client_id) UNIQUE
#

# frozen_string_literal: true

class UserClient < IdentitiesRecord
  belongs_to :user
  belongs_to :client

  validates :client_id, uniqueness: { scope: :user_id }
end
