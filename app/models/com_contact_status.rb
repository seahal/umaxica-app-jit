class ComContactStatus < ContactStatus
  has_many :app_contacts,
           foreign_key: :contact_status_title,
           primary_key: :title,
           inverse_of: :app_contact_status,
           dependent: :nullify
end
