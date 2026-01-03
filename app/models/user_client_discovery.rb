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

class UserClientDiscovery < IdentityRecord
  belongs_to :user, inverse_of: :user_client_discoveries
  belongs_to :client, inverse_of: :user_client_discoveries

  validates :client_id, uniqueness: { scope: :user_id }
end
