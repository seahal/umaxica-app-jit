# == Schema Information
#
# Table name: com_document_category_masters
# Database name: document
#
#  id        :bigint           not null, primary key
#  code      :citext           not null
#  parent_id :bigint           not null
#
# Indexes
#
#  index_com_document_category_masters_on_code       (code) UNIQUE
#  index_com_document_category_masters_on_parent_id  (parent_id)
#
# Foreign Keys
#
#  fk_rails_...  (parent_id => com_document_category_masters.id)
#

# frozen_string_literal: true

class ComDocumentCategoryMaster < DocumentRecord
  include CodeIdentifiable
  include Treeable

  belongs_to :parent,
             class_name: "ComDocumentCategoryMaster",
             inverse_of: :children,
             optional: true
  has_many :children,
           class_name: "ComDocumentCategoryMaster",
           foreign_key: :parent_id,
           inverse_of: :parent,
           dependent: :restrict_with_error
  has_many :com_document_categories,
           dependent: :restrict_with_error,
           inverse_of: :com_document_category_master
  has_many :com_documents, through: :com_document_categories

  self.primary_key = "id"

  attribute :parent_id, default: "NEYO"

  validates :parent_id, presence: true, length: { maximum: 255 }

  def name
    I18n.t("com_document_categorys.%{id}", id: id)
  end

  def root?
    parent_id == "NEYO"
  end
end
