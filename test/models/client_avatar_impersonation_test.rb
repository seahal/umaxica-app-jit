# == Schema Information
#
# Table name: client_avatar_impersonations
#
#  id         :uuid             not null, primary key
#  client_id  :uuid             not null
#  avatar_id  :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_client_avatar_impersonations_on_avatar_id          (avatar_id)
#  index_client_avatar_impersonations_on_client_and_avatar  (client_id,avatar_id) UNIQUE
#  index_client_avatar_impersonations_on_client_id          (client_id)
#

# frozen_string_literal: true

require "test_helper"

class ClientAvatarImpersonationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
