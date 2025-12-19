# frozen_string_literal: true

class OrgContactStatus < GuestsRecord
  include UppercaseId

  has_many :org_contacts,
           foreign_key: :contact_status_id,
           inverse_of: :org_contact_status,
           dependent: :nullify
end
