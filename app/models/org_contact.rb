class OrgContact < GuestsRecord
  belongs_to :org_contact_category,
             class_name: "OrgContactCategory",
             foreign_key: :contact_category_title,
             primary_key: :title,
             optional: true,
             inverse_of: :org_contacts
  belongs_to :org_contact_status,
             class_name: "OrgContactStatus",
             foreign_key: :contact_status_title,
             primary_key: :title,
             optional: true,
             inverse_of: :org_contacts

  after_initialize :set_default_category_and_status, if: :new_record?

  before_save { self.email_address&.downcase! }
  before_save { self.telephone_number&.downcase! }

  private

  def set_default_category_and_status
    self.contact_category_title ||= "NULL_ORG_CATEGORY"
    self.contact_status_title ||= "NULL_CONTACT_STATUS"
  end
end
