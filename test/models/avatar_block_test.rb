# == Schema Information
#
# Table name: avatar_blocks
# Database name: avatar
#
#  id                :bigint           not null, primary key
#  expires_at        :datetime
#  reason            :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  blocked_avatar_id :bigint           not null
#  blocker_avatar_id :bigint           not null
#
# Indexes
#
#  index_avatar_blocks_on_blocked_avatar_id  (blocked_avatar_id)
#  index_avatar_blocks_on_blocker_avatar_id  (blocker_avatar_id)
#
# Foreign Keys
#
#  fk_rails_...  (blocked_avatar_id => avatars.id)
#  fk_rails_...  (blocker_avatar_id => avatars.id)
#

# frozen_string_literal: true

require "test_helper"

class AvatarBlockTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
