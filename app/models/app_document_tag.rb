# == Schema Information
#
# Table name: app_document_tags
#
#  id                         :uuid             not null, primary key
#  app_document_id            :uuid             not null
#  app_document_tag_master_id :string(255)      not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_app_document_tags_on_app_document_tag_master_id  (app_document_tag_master_id)
#  index_app_document_tags_on_document_and_tag            (app_document_id,app_document_tag_master_id) UNIQUE
#

# frozen_string_literal: true

class AppDocumentTag < DocumentRecord
  include ::CatTag

  belongs_to :app_document, inverse_of: :app_document_tags
  belongs_to :app_document_tag_master,
             primary_key: :id,
             inverse_of: :app_document_tags

  validates :app_document_tag_master_id,
            length: { maximum: 255 },
            uniqueness: { scope: :app_document_id,
                          message: :already_tagged, }
end
