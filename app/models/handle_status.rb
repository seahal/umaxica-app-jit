# frozen_string_literal: true

# == Schema Information
#
# Table name: handle_statuses
# Database name: avatar
#
#  id :string           not null, primary key
#
class HandleStatus < AvatarRecord
  include StringPrimaryKey

  self.record_timestamps = false

  has_many :handles, dependent: :restrict_with_error
end
