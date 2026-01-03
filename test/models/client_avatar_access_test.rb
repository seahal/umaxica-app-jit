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
#  index_client_avatar_accesses_on_client_id                (client_id)
#  index_client_avatar_accesses_on_client_id_and_avatar_id  (client_id,avatar_id) UNIQUE
#

# frozen_string_literal: true

require "test_helper"

class ClientAvatarAccessTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
