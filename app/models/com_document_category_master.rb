# == Schema Information
#
# Table name: com_document_category_masters
#
#  id         :string(255)      not null, primary key
#  parent_id  :string(255)      default("none"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_com_document_category_masters_on_parent_id  (parent_id)
#

# frozen_string_literal: true

class ComDocumentCategoryMaster < DocumentRecord
  include ::CatTagMaster

  self.primary_key = "id"

  belongs_to :parent,
             class_name: "ComDocumentCategoryMaster",
             inverse_of: :children,
             optional: true

  has_many :children,
           class_name: "ComDocumentCategoryMaster",
           foreign_key: :parent_id,
           inverse_of: :parent,
           dependent: :restrict_with_error

  has_many :com_document_categories, dependent: :restrict_with_error
  has_many :com_documents, through: :com_document_categories

  validates :id, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :parent_id, presence: true, length: { maximum: 255 }

  def name
    I18n.t("com_document_categories.%{id}", id: id)
  end

  def root?
    parent_id == "NEYO"
  end
end
