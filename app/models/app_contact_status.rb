class AppContactStatus < GuestsRecord
  include UppercaseId

  has_many :app_contacts,
           foreign_key: :contact_status_id,
           inverse_of: :app_contact_status,
           dependent: :nullify
end
