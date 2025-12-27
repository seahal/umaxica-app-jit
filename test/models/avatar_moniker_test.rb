# frozen_string_literal: true

# == Schema Information
#
# Table name: avatar_monikers
#
#  id                       :string           not null, primary key
#  avatar_id                :string           not null
#  moniker                  :string           not null
#  valid_from               :timestamptz      not null
#  valid_to                 :timestamptz      default("infinity"), not null
#  avatar_moniker_status_id :string
#  set_by_actor_id          :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#
# Indexes
#
#  index_avatar_monikers_on_avatar_id                 (avatar_id) UNIQUE
#  index_avatar_monikers_on_avatar_id_and_valid_from  (avatar_id,valid_from)
#  index_avatar_monikers_on_avatar_moniker_status_id  (avatar_moniker_status_id)
#

require "test_helper"

class AvatarMonikerTest < ActiveSupport::TestCase
  test "validations" do
    moniker = AvatarMoniker.new
    assert_not moniker.valid?
  end
end
