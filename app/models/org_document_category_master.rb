# == Schema Information
#
# Table name: org_document_category_masters
# Database name: document
#
#  id        :bigint           not null, primary key
#  code      :citext           not null
#  parent_id :bigint           not null
#
# Indexes
#
#  index_org_document_category_masters_on_code       (code) UNIQUE
#  index_org_document_category_masters_on_parent_id  (parent_id)
#
# Foreign Keys
#
#  fk_rails_...  (parent_id => org_document_category_masters.id)
#

# frozen_string_literal: true

class OrgDocumentCategoryMaster < DocumentRecord
  include CodeIdentifiable
  include Treeable

  belongs_to :parent,
             class_name: "OrgDocumentCategoryMaster",
             inverse_of: :children,
             optional: true
  has_many :children,
           class_name: "OrgDocumentCategoryMaster",
           foreign_key: :parent_id,
           inverse_of: :parent,
           dependent: :restrict_with_error
  has_many :org_document_categories,
           dependent: :restrict_with_error,
           inverse_of: :org_document_category_master
  has_many :org_documents, through: :org_document_categories

  self.primary_key = "id"

  attribute :parent_id, default: "NEYO"

  validates :parent_id, presence: true, length: { maximum: 255 }

  def name
    I18n.t("org_document_categorys.%{id}", id: id)
  end

  def root?
    parent_id == "NEYO"
  end
end
