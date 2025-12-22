class AppContactCategory < GuestsRecord
  include UppercaseId

  has_many :app_contacts,
           foreign_key: :contact_category_title,
           primary_key: :id,
           dependent: :nullify,
           inverse_of: :app_contact_category
end
