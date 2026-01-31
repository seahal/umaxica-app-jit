# == Schema Information
#
# Table name: com_document_categories
# Database name: document
#
#  id                              :uuid             not null, primary key
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  com_document_category_master_id :integer          default(0), not null
#  com_document_id                 :uuid             not null
#
# Indexes
#
#  idx_on_com_document_category_master_id_dc650e897c  (com_document_category_master_id)
#  index_com_document_categories_on_com_document_id   (com_document_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (com_document_category_master_id => com_document_category_masters.id)
#  fk_rails_...  (com_document_id => com_documents.id) ON DELETE => cascade
#

# frozen_string_literal: true

class ComDocumentCategory < DocumentRecord
  include ::CatTag

  belongs_to :com_document, inverse_of: :category
  belongs_to :com_document_category_master,
             primary_key: :id,
             inverse_of: :com_document_categories

  validates :com_document_id, uniqueness: true
  validates :com_document_category_master_id, length: { maximum: 255 }
end
