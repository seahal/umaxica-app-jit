# frozen_string_literal: true

# == Schema Information
#
# Table name: com_contact_statuses
# Database name: guest
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_com_contact_statuses_on_code  (code) UNIQUE
#

class ComContactStatus < GuestRecord
  include CodeIdentifiable

  has_many :com_contacts,
           foreign_key: :status_id,
           inverse_of: :com_contact_status,
           dependent: :nullify

  validates :description, length: { maximum: 255 }
end
