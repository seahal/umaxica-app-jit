# == Schema Information
#
# Table name: org_document_tags
#
#  id                         :uuid             not null, primary key
#  org_document_id            :uuid             not null
#  org_document_tag_master_id :string(255)      not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_org_document_taggers_on_document_and_tag         (org_document_id,org_document_tag_master_id) UNIQUE
#  index_org_document_tags_on_org_document_tag_master_id  (org_document_tag_master_id)
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
