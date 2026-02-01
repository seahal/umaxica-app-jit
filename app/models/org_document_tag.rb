# == Schema Information
#
# Table name: org_document_tags
# Database name: document
#
#  id                         :bigint           not null, primary key
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  org_document_id            :bigint           not null
#  org_document_tag_master_id :integer          default(0), not null
#
# Indexes
#
#  index_org_document_tags_on_org_document_tag_master_id  (org_document_tag_master_id)
#
# Foreign Keys
#
#  fk_rails_...  (org_document_id => org_documents.id) ON DELETE => cascade
#  fk_rails_...  (org_document_tag_master_id => org_document_tag_masters.id)
#

# frozen_string_literal: true

class OrgDocumentTag < DocumentRecord
  include ::CatTag

  belongs_to :org_document, inverse_of: :org_document_tags
  belongs_to :org_document_tag_master,
             primary_key: :id,
             inverse_of: :org_document_tags

  validates :org_document_tag_master_id,
            length: { maximum: 255 },
            uniqueness: { scope: :org_document_id,
                          message: :already_tagged, }
end
