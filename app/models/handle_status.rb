# frozen_string_literal: true

# == Schema Information
#
# Table name: handle_statuses
# Database name: avatar
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_handle_statuses_on_code  (code) UNIQUE
#
class HandleStatus < AvatarRecord
  include CodeIdentifiable

  self.record_timestamps = false

  has_many :handles, dependent: :restrict_with_error
end
