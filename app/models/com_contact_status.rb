# frozen_string_literal: true

class ComContactStatus < GuestsRecord
  include UppercaseId

  has_many :com_contacts,
           foreign_key: :contact_status_id,
           inverse_of: :com_contact_status,
           dependent: :nullify
end
