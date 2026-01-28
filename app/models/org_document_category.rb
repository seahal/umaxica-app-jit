# == Schema Information
#
# Table name: org_document_categories
# Database name: document
#
#  id                              :uuid             not null, primary key
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  org_document_category_master_id :string(255)      not null
#  org_document_id                 :uuid             not null
#
# Indexes
#
#  idx_on_org_document_category_master_id_0d3d809e93  (org_document_category_master_id)
#  index_org_document_categories_on_org_document_id   (org_document_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (org_document_category_master_id => org_document_category_masters.id)
#  fk_rails_...  (org_document_id => org_documents.id) ON DELETE => cascade
#

# frozen_string_literal: true

class OrgDocumentCategory < DocumentRecord
  include ::CatTag

  belongs_to :org_document, inverse_of: :category
  belongs_to :org_document_category_master,
             primary_key: :id,
             inverse_of: :org_document_categories

  validates :org_document_id, uniqueness: true
  validates :org_document_category_master_id, length: { maximum: 255 }
end
