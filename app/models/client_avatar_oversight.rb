# == Schema Information
#
# Table name: client_avatar_oversights
# Database name: avatar
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  avatar_id  :bigint           not null
#  client_id  :uuid             not null
#
# Indexes
#
#  index_client_avatar_oversights_on_avatar_id          (avatar_id)
#  index_client_avatar_oversights_on_client_and_avatar  (client_id,avatar_id) UNIQUE
#  index_client_avatar_oversights_on_client_id          (client_id)
#
# Foreign Keys
#
#  fk_rails_...  (avatar_id => avatars.id)
#

# frozen_string_literal: true

class ClientAvatarOversight < AvatarRecord
  belongs_to :client, inverse_of: :client_avatar_oversights
  belongs_to :avatar, inverse_of: :client_avatar_oversights

  validates :avatar_id, uniqueness: { scope: :client_id }
end
