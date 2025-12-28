# frozen_string_literal: true

# == Schema Information
#
# Table name: org_contact_categories
#
#  id          :string(255)      not null, primary key
#  active      :boolean          default(TRUE), not null
#  created_at  :datetime         not null
#  description :string(255)      default(""), not null
#  parent_id   :string(255)      default(""), not null
#  position    :integer          default(0), not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_org_contact_categories_on_parent_id  (parent_id)
#

class OrgContactCategory < GuestsRecord
  include UppercaseId

  EMPTY_STRING = ""

  belongs_to :parent,
             class_name: "OrgContactCategory",
             inverse_of: :children,
             optional: true

  has_many :children,
           class_name: "OrgContactCategory",
           foreign_key: :parent_id,
           inverse_of: :parent,
           dependent: :restrict_with_error

  has_many :org_contacts,
           foreign_key: :category_id,
           primary_key: :id,
           inverse_of: :org_contact_category,
           dependent: :nullify

  validates :description, length: { maximum: 255 }
  validates :parent_id, length: { maximum: 255 }, allow_blank: true

  def root?
    parent_id == EMPTY_STRING
  end
end
