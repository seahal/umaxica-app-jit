class OrgContactStatus <  GuestsRecord
  has_many :org_contacts,
           foreign_key: :contact_status_title,
           primary_key: :title,
           inverse_of: :org_contact_status,
           dependent: :nullify
end
