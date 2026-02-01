# == Schema Information
#
# Table name: user_client_suspensions
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
#  index_user_client_suspensions_on_client_id              (client_id)
#  index_user_client_suspensions_on_user_id_and_client_id  (user_id,client_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (user_id => users.id)
#

# frozen_string_literal: true

class UserClientSuspension < PrincipalRecord
  belongs_to :user, inverse_of: :user_client_suspensions
  belongs_to :client, inverse_of: :user_client_suspensions

  validates :client_id, uniqueness: { scope: :user_id }
end
