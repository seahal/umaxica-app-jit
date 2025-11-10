class ComContactStatus <  GuestsRecord
  has_many :com_contacts,
           foreign_key: :contact_status_title,
           primary_key: :title,
           inverse_of: :com_contact_status,
           dependent: :nullify
end
