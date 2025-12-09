# NOTE: For Regional usage.

class AppContactCategory < GuestsRecord
  self.primary_key = :title

  has_many :app_contacts,
           foreign_key: :contact_category_title,
           primary_key: :title,
           dependent: :nullify,
           inverse_of: :app_contact_category
end
