class OrgContact < GuestsRecord
  belongs_to :org_contact_status,
             class_name: "OrgContactStatus",
             foreign_key: :contact_status_title,
             primary_key: :title,
             optional: true,
             inverse_of: :org_contacts

  before_save { self.email_address&.downcase! }
  before_save { self.telephone_number&.downcase! }
end
