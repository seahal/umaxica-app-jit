# frozen_string_literal: true

# == Schema Information
#
# Table name: avatar_moniker_statuses
# Database name: avatar
#
#  id :integer          not null, primary key
#
# Indexes
#
#  index_avatar_moniker_statuses_on_id  (id) UNIQUE
#
class AvatarMonikerStatus < AvatarRecord
  include CodeIdentifiable

  self.record_timestamps = false

  has_many :avatar_monikers, dependent: :restrict_with_error
end
