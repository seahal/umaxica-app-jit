# == Schema Information
#
# Table name: user_client_suspensions
#
#  id         :uuid             not null, primary key
#  user_id    :uuid             not null
#  client_id  :uuid             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_user_client_suspensions_on_client_id              (client_id)
#  index_user_client_suspensions_on_user_id                (user_id)
#  index_user_client_suspensions_on_user_id_and_client_id  (user_id,client_id) UNIQUE
#

# frozen_string_literal: true

class UserClientSuspension < IdentityRecord
  belongs_to :user, inverse_of: :user_client_suspensions
  belongs_to :client, inverse_of: :user_client_suspensions
end
