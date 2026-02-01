# frozen_string_literal: true

# == Schema Information
#
# Table name: handle_statuses
# Database name: avatar
#
#  id :integer          not null, primary key
#
# Indexes
#
#  index_handle_statuses_on_id  (id) UNIQUE
#
class HandleStatus < AvatarRecord
  include CodeIdentifiable

  self.record_timestamps = false

  has_many :handles, dependent: :restrict_with_error
end
