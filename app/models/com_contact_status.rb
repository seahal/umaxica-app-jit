# frozen_string_literal: true

# == Schema Information
#
# Table name: com_contact_statuses
# Database name: guest
#
#  id :integer          not null, primary key
#
# Indexes
#
#  index_com_contact_statuses_on_id  (id) UNIQUE
#

class ComContactStatus < GuestRecord
  include StringPrimaryKey

  has_many :com_contacts,
           foreign_key: :status_id,
           inverse_of: :com_contact_status,
           dependent: :nullify
  validates :id, uniqueness: { case_sensitive: false }

  validates :description, length: { maximum: 255 }
end
