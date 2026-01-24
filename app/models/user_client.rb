# == Schema Information
#
# Table name: user_clients
# Database name: principal
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  client_id  :uuid             not null
#  user_id    :uuid             not null
#
# Indexes
#
#  index_user_clients_on_client_id              (client_id)
#  index_user_clients_on_user_id                (user_id)
#  index_user_clients_on_user_id_and_client_id  (user_id,client_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id) ON DELETE => cascade
#  fk_rails_...  (user_id => users.id) ON DELETE => cascade
#

# frozen_string_literal: true

class UserClient < PrincipalRecord
  belongs_to :user
  belongs_to :client

  validates :client_id, uniqueness: { scope: :user_id }
end
