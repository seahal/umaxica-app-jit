# frozen_string_literal: true

class AppContactStatus < GuestsRecord
  include UppercaseIdValidation

  has_many :app_contacts,
           foreign_key: :contact_status_id,
           inverse_of: :app_contact_status,
           dependent: :nullify
end
