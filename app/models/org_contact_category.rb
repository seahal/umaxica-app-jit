# frozen_string_literal: true

class OrgContactCategory < GuestsRecord
  self.primary_key = :title

  include UppercaseTitleValidation

  has_many :org_contacts,
           foreign_key: :contact_category_title,
           primary_key: :title,
           inverse_of: :org_contact_category,
           dependent: :nullify
end
