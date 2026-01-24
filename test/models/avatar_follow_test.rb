# == Schema Information
#
# Table name: avatar_follows
# Database name: avatar
#
#  id                 :uuid             not null, primary key
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  followed_avatar_id :string           not null
#  follower_avatar_id :string           not null
#
# Indexes
#
#  index_avatar_follows_on_followed_avatar_id  (followed_avatar_id)
#  index_avatar_follows_on_follower_avatar_id  (follower_avatar_id)
#
# Foreign Keys
#
#  fk_rails_...  (followed_avatar_id => avatars.id)
#  fk_rails_...  (follower_avatar_id => avatars.id)
#

# frozen_string_literal: true

require "test_helper"

class AvatarFollowTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
