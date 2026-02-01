# == Schema Information
#
# Table name: app_document_categories
# Database name: document
#
#  id                              :bigint           not null, primary key
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  app_document_category_master_id :integer          default(0), not null
#  app_document_id                 :bigint           not null
#
# Indexes
#
#  idx_on_app_document_category_master_id_018a74a5ab  (app_document_category_master_id)
#  index_app_document_categories_on_app_document_id   (app_document_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (app_document_category_master_id => app_document_category_masters.id)
#  fk_rails_...  (app_document_id => app_documents.id) ON DELETE => cascade
#

# frozen_string_literal: true

class AppDocumentCategory < DocumentRecord
  include ::CatTag

  belongs_to :app_document, inverse_of: :category
  belongs_to :app_document_category_master,
             primary_key: :id,
             inverse_of: :app_document_categories

  validates :app_document_id, uniqueness: true
  validates :app_document_category_master_id, length: { maximum: 255 }
end
