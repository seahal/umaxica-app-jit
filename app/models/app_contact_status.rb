# frozen_string_literal: true

# == Schema Information
#
# Table name: app_contact_statuses
# Database name: guest
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_app_contact_statuses_on_code  (code) UNIQUE
#

class AppContactStatus < GuestRecord
  include CodeIdentifiable

  has_many :app_contacts,
           foreign_key: :status_id,
           inverse_of: :app_contact_status,
           dependent: :restrict_with_exception

  validates :description, length: { maximum: 255 }
end
