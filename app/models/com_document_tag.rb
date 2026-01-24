# == Schema Information
#
# Table name: com_document_tags
# Database name: document
#
#  id                         :uuid             not null, primary key
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  com_document_id            :uuid             not null
#  com_document_tag_master_id :string(255)      not null
#
# Indexes
#
#  index_com_document_tags_on_com_document_tag_master_id  (com_document_tag_master_id)
#  index_com_document_tags_on_document_and_tag            (com_document_id,com_document_tag_master_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (com_document_id => com_documents.id) ON DELETE => cascade
#  fk_rails_...  (com_document_tag_master_id => com_document_tag_masters.id)
#

# frozen_string_literal: true

class ComDocumentTag < DocumentRecord
  include ::CatTag

  belongs_to :com_document, inverse_of: :com_document_tags
  belongs_to :com_document_tag_master,
             primary_key: :id,
             inverse_of: :com_document_tags

  validates :com_document_tag_master_id,
            length: { maximum: 255 },
            uniqueness: { scope: :com_document_id,
                          message: :already_tagged, }
end
