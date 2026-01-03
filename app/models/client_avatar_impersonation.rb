# == Schema Information
#
# Table name: client_avatar_impersonations
#
#  id         :uuid             not null, primary key
#  client_id  :uuid             not null
#  avatar_id  :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_client_avatar_impersonations_on_avatar_id          (avatar_id)
#  index_client_avatar_impersonations_on_client_and_avatar  (client_id,avatar_id) UNIQUE
#  index_client_avatar_impersonations_on_client_id          (client_id)
#

# frozen_string_literal: true

class ClientAvatarImpersonation < IdentityRecord
  belongs_to :client, inverse_of: :client_avatar_impersonations
  belongs_to :avatar, inverse_of: :client_avatar_impersonations

  validates :avatar_id, uniqueness: { scope: :client_id }
end
