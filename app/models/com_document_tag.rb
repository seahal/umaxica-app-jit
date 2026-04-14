# typed: false
# == Schema Information
#
# Table name: com_document_tags
# Database name: publication
#
#  id                         :bigint           not null, primary key
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  com_document_id            :bigint           not null
#  com_document_tag_master_id :bigint           default(0), not null
#
# Indexes
#
#  idx_on_com_document_tag_master_id_com_document_id_93b8da9f9e  (com_document_tag_master_id,com_document_id) UNIQUE
#  index_com_document_tags_on_com_document_id                    (com_document_id)
#
# Foreign Keys
#
#  fk_rails_...  (com_document_id => com_documents.id)
#  fk_rails_...  (com_document_tag_master_id => com_document_tag_masters.id)
#

# frozen_string_literal: true

class ComDocumentTag < PublicationRecord
  include ::CategoryTag

  belongs_to :com_document, inverse_of: :com_document_tags
  belongs_to :com_document_tag_master,
             primary_key: :id,
             inverse_of: :com_document_tags

  validates :com_document_tag_master_id,
            length: { maximum: 255 },
            uniqueness: { scope: :com_document_id,
                          message: :already_tagged, }
end
