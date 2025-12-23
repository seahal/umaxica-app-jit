class OrgContactCategory < GuestsRecord
  include UppercaseId

  has_many :org_contacts,
           foreign_key: :contact_category_title,
           primary_key: :id,
           inverse_of: :org_contact_category,
           dependent: :nullify
end
