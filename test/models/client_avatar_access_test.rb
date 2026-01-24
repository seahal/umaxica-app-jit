# == Schema Information
#
# Table name: client_avatar_accesses
# Database name: avatar
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  avatar_id  :string           not null
#  client_id  :uuid             not null
#
# Indexes
#
#  index_client_avatar_accesses_on_avatar_id                (avatar_id)
#  index_client_avatar_accesses_on_client_id                (client_id)
#  index_client_avatar_accesses_on_client_id_and_avatar_id  (client_id,avatar_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (avatar_id => avatars.id)
#

# frozen_string_literal: true

require "test_helper"

class ClientAvatarAccessTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
