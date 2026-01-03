# == Schema Information
#
# Table name: client_avatar_deletions
#
#  id         :uuid             not null, primary key
#  client_id  :uuid             not null
#  avatar_id  :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_client_avatar_deletions_on_avatar_id          (avatar_id)
#  index_client_avatar_deletions_on_client_and_avatar  (client_id,avatar_id) UNIQUE
#  index_client_avatar_deletions_on_client_id          (client_id)
#

# frozen_string_literal: true

class ClientAvatarDeletion < IdentityRecord
  belongs_to :client, inverse_of: :client_avatar_deletions
  belongs_to :avatar, inverse_of: :client_avatar_deletions
end
