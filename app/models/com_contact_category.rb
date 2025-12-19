# frozen_string_literal: true

class ComContactCategory < GuestsRecord
  self.primary_key = :title

  include UppercaseTitle

  has_many :com_contacts,
           foreign_key: :contact_category_title,
           primary_key: :title,
           inverse_of: :com_contact_category,
           dependent: :nullify
end
