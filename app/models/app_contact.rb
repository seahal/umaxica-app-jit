# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: app_contacts
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
#  index_app_contacts_on_category_id  (category_id)
#  index_app_contacts_on_public_id    (public_id) UNIQUE
#  index_app_contacts_on_status_id    (status_id)
#
# Foreign Keys
#
#  fk_rails_...  (category_id => app_contact_categories.id)
#  fk_rails_...  (status_id => app_contact_statuses.id) ON DELETE => restrict
#

class AppContact < GuestRecord
  include ::PublicId

  attr_accessor :confirm_policy

  # Associations
  belongs_to :app_contact_category,
             class_name: "AppContactCategory",
             foreign_key: :category_id,
             primary_key: :id,
             inverse_of: :app_contacts
  belongs_to :app_contact_status,
             class_name: "AppContactStatus",
             foreign_key: :status_id,
             inverse_of: :app_contacts
  has_many :app_contact_topics, dependent: :destroy, inverse_of: :app_contact
  has_many :app_contact_emails, dependent: :destroy, inverse_of: :app_contact
  has_many :app_contact_telephones, dependent: :destroy, inverse_of: :app_contact

  after_initialize do
    if new_record?
      self.category_id = AppContactCategory::APPLICATION_INQUIRY if category_id.blank? || category_id.to_i.zero?
      self.status_id = AppContactStatus::NOTHING if status_id.blank? || status_id.to_i.zero?
    end
  end

  # Validations
  validates :confirm_policy, acceptance: true

  # Override to_param to use public_id in URLs
  def to_param
    public_id
  end
end
