# frozen_string_literal: true

# == Schema Information
#
# Table name: org_contact_categories
# Database name: guest
#
#  id :string(255)      not null, primary key
#
# Indexes
#
#  index_org_contact_categories_on_lower_id  (lower((id)::text)) UNIQUE
#

class OrgContactCategory < GuestRecord
  include StringPrimaryKey

  has_many :org_contacts,
           foreign_key: :category_id,
           primary_key: :id,
           inverse_of: :org_contact_category,
           dependent: :restrict_with_error
  validates :id, uniqueness: { case_sensitive: false }

  validates :description, length: { maximum: 255 }
end
