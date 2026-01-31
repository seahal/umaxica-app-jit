# frozen_string_literal: true

# == Schema Information
#
# Table name: avatar_moniker_statuses
# Database name: avatar
#
#  id :string           not null, primary key
#
class AvatarMonikerStatus < AvatarRecord
  include StringPrimaryKey

  self.record_timestamps = false

  has_many :avatar_monikers, dependent: :restrict_with_error
end
