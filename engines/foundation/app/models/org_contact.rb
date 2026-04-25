# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: org_contacts
# Database name: guest
#
#  id          :bigint           not null, primary key
#  ip_address  :inet
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  category_id :bigint           default(0), not null
#  public_id   :string(21)       not null
#  status_id   :bigint           not null
#
# Indexes
#
#  index_org_contacts_on_category_id  (category_id)
#  index_org_contacts_on_public_id    (public_id) UNIQUE
#  index_org_contacts_on_status_id    (status_id)
#
# Foreign Keys
#
#  fk_org_contacts_on_status_id_nullify  (status_id => org_contact_statuses.id) ON DELETE => nullify
#  fk_rails_...                          (category_id => org_contact_categories.id)
#

class OrgContact < GuestRecord
  include ::PublicId

  attr_accessor :confirm_policy

  # Associations
  has_many :org_contact_emails, dependent: :destroy, inverse_of: :org_contact
  has_many :org_contact_telephones, dependent: :destroy, inverse_of: :org_contact
  belongs_to :org_contact_category,
             class_name: "OrgContactCategory",
             foreign_key: :category_id,
             primary_key: :id,
             inverse_of: :org_contacts
  belongs_to :org_contact_status,
             class_name: "OrgContactStatus",
             foreign_key: :status_id,
             inverse_of: :org_contacts
  has_many :org_contact_topics, dependent: :destroy, inverse_of: :org_contact

  after_initialize do
    if new_record?
      self.category_id = OrgContactCategory::ORGANIZATION_INQUIRY if category_id.blank? || category_id.to_i.zero?
      self.status_id = OrgContactStatus::NOTHING if status_id.blank? || status_id.to_i.zero?
    end
  end

  # Validations
  validates :confirm_policy, acceptance: true

  # Override to_param to use public_id in URLs
  def to_param
    public_id
  end
end
