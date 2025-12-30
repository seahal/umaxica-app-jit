# frozen_string_literal: true

# == Schema Information
#
# Table name: org_contact_statuses
#
#  id          :string(255)      not null, primary key
#

class OrgContactStatus < GuestsRecord
  include UppercaseId

  validates :description, length: { maximum: 255 }

  has_many :org_contacts,
           foreign_key: :status_id,
           inverse_of: :org_contact_status,
           dependent: :nullify
end
