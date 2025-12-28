# == Schema Information
#
# Table name: org_document_category_masters
#
#  id         :string(255)      not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  parent_id  :string(255)      default("none"), not null
#
# Indexes
#
#  index_org_document_category_masters_on_parent_id  (parent_id)
#

# frozen_string_literal: true

class OrgDocumentCategoryMaster < DocumentRecord
  include UppercaseId
  include ::CatTagMaster

  self.primary_key = "id"

  belongs_to :parent,
             class_name: "OrgDocumentCategoryMaster",
             inverse_of: :children,
             optional: true

  has_many :children,
           class_name: "OrgDocumentCategoryMaster",
           foreign_key: :parent_id,
           inverse_of: :parent,
           dependent: :restrict_with_error

  has_many :org_document_categories, dependent: :restrict_with_error
  has_many :org_documents, through: :org_document_categories

  validates :id, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :parent_id, presence: true, length: { maximum: 255 }

  def name
    I18n.t("org_document_categories.%{id}", id: id)
  end

  def root?
    parent_id == "NEYO"
  end
end
