# typed: false
# == Schema Information
#
# Table name: app_document_tags
# Database name: publication
#
#  id                         :bigint           not null, primary key
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  app_document_id            :bigint           not null
#  app_document_tag_master_id :bigint           default(0), not null
#
# Indexes
#
#  idx_on_app_document_tag_master_id_app_document_id_75ee747154  (app_document_tag_master_id,app_document_id) UNIQUE
#  index_app_document_tags_on_app_document_id                    (app_document_id)
#
# Foreign Keys
#
#  fk_rails_...  (app_document_id => app_documents.id)
#  fk_rails_...  (app_document_tag_master_id => app_document_tag_masters.id)
#

# frozen_string_literal: true

class AppDocumentTag < PublicationRecord
  include ::CategoryTag

  belongs_to :app_document, inverse_of: :app_document_tags
  belongs_to :app_document_tag_master,
             primary_key: :id,
             inverse_of: :app_document_tags

  validates :app_document_tag_master_id,
            length: { maximum: 255 },
            uniqueness: { scope: :app_document_id,
                          message: :already_tagged, }
end
