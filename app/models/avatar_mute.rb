# == Schema Information
#
# Table name: avatar_mutes
#
#  id              :uuid             not null, primary key
#  muter_avatar_id :string           not null
#  muted_avatar_id :string           not null
#  expires_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_avatar_mutes_on_muted_avatar_id  (muted_avatar_id)
#  index_avatar_mutes_on_muter_avatar_id  (muter_avatar_id)
#

# frozen_string_literal: true

class AvatarMute < IdentitiesRecord
  self.implicit_order_column = :created_at
  belongs_to :muter_avatar,
             class_name: "Avatar",
             inverse_of: :outgoing_mutes
  belongs_to :muted_avatar,
             class_name: "Avatar"
end
