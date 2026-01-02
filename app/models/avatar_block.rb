# == Schema Information
#
# Table name: avatar_blocks
#
#  id                :uuid             not null, primary key
#  blocker_avatar_id :string           not null
#  blocked_avatar_id :string           not null
#  reason            :string
#  expires_at        :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_avatar_blocks_on_blocked_avatar_id  (blocked_avatar_id)
#  index_avatar_blocks_on_blocker_avatar_id  (blocker_avatar_id)
#

# frozen_string_literal: true

class AvatarBlock < IdentitiesRecord
  self.implicit_order_column = :created_at
  belongs_to :blocker_avatar,
             class_name: "Avatar",
             inverse_of: :outgoing_blocks
  belongs_to :blocked_avatar,
             class_name: "Avatar"
end
