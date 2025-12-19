# frozen_string_literal: true

class ComContactCategory < GuestsRecord
  include UppercaseId

  has_many :com_contacts,
           foreign_key: :contact_category_title,
           primary_key: :id,
           inverse_of: :com_contact_category,
           dependent: :nullify
end
