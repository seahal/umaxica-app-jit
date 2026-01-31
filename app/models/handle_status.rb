# frozen_string_literal: true

# == Schema Information
#
# Table name: handle_statuses
# Database name: avatar
#
#  id :integer          not null, primary key, limit: 2
#
class HandleStatus < AvatarRecord
  self.record_timestamps = false

  has_many :handles, dependent: :restrict_with_error
end
