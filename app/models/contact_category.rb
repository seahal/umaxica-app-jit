class ContactCategory < GuestsRecord
  self.primary_key = :title

  has_many :corporate_site_contacts,
           foreign_key: :contact_category_title,
           primary_key: :title,
           inverse_of: :corporate_site_contact_category,
           dependent: :nullify
end
