# frozen_string_literal: true

# == Schema Information
#
# Table name: org_contact_statuses
# Database name: guest
#
#  id :integer          not null, primary key
#
# Indexes
#
#  index_org_contact_statuses_on_id  (id) UNIQUE
#

class OrgContactStatus < GuestRecord
  include StringPrimaryKey

  has_many :org_contacts,
           foreign_key: :status_id,
           inverse_of: :org_contact_status,
           dependent: :nullify
  validates :id, uniqueness: { case_sensitive: false }

  validates :description, length: { maximum: 255 }
end
