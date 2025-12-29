# == Schema Information
#
# Table name: app_document_category_masters
#
#  id         :string(255)      not null, primary key
#  parent_id  :string(255)      default("NEYO"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_app_document_category_masters_on_parent_id  (parent_id)
#

# frozen_string_literal: true

class AppDocumentCategoryMaster < DocumentRecord
  include UppercaseId
  include ::CatTagMaster

  self.primary_key = "id"

  belongs_to :parent,
             class_name: "AppDocumentCategoryMaster",
             inverse_of: :children,
             optional: true

  has_many :children,
           class_name: "AppDocumentCategoryMaster",
           foreign_key: :parent_id,
           inverse_of: :parent,
           dependent: :restrict_with_error

  has_many :app_document_categories, dependent: :restrict_with_error
  has_many :app_documents, through: :app_document_categories

  validates :id, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :parent_id, presence: true, length: { maximum: 255 }

  def name
    I18n.t("app_document_categories.%{id}", id: id)
  end

  def root?
    parent_id == "NEYO"
  end
end
