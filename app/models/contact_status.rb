class ContactStatus < GuestsRecord
  self.primary_key = :title

  has_many :corporate_site_contacts,
           foreign_key: :contact_status_title,
           primary_key: :title,
           inverse_of: :corporate_site_contact_status,
           dependent: :nullify
end
