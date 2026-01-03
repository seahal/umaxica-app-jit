# == Schema Information
#
# Table name: client_avatar_accesses
#
#  id         :uuid             not null, primary key
#  client_id  :uuid             not null
#  avatar_id  :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_client_avatar_accesses_on_avatar_id                (avatar_id)
#  index_client_avatar_accesses_on_client_id_and_avatar_id  (client_id,avatar_id) UNIQUE
#

# frozen_string_literal: true

class ClientAvatarAccess < IdentityRecord
  belongs_to :client, inverse_of: :client_avatar_accesses
  belongs_to :avatar, inverse_of: :client_avatar_accesses

  validates :client_id, uniqueness: { scope: :avatar_id }
end
