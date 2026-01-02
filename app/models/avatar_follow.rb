# == Schema Information
#
# Table name: avatar_follows
#
#  id                 :uuid             not null, primary key
#  follower_avatar_id :string           not null
#  followed_avatar_id :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_avatar_follows_on_followed_avatar_id  (followed_avatar_id)
#  index_avatar_follows_on_follower_avatar_id  (follower_avatar_id)
#

# frozen_string_literal: true

class AvatarFollow < IdentitiesRecord
  self.implicit_order_column = :created_at
  belongs_to :follower_avatar,
             class_name: "Avatar",
             inverse_of: :outgoing_follows
  belongs_to :followed_avatar,
             class_name: "Avatar",
             inverse_of: :incoming_follows
end
