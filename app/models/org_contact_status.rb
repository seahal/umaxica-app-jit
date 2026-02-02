# frozen_string_literal: true

# == Schema Information
#
# Table name: org_contact_statuses
# Database name: guest
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_org_contact_statuses_on_code  (code) UNIQUE
#

class OrgContactStatus < GuestRecord
  include CodeIdentifiable

  has_many :org_contacts,
           foreign_key: :status_id,
           inverse_of: :org_contact_status,
           dependent: :nullify

  validates :description, length: { maximum: 255 }
end
