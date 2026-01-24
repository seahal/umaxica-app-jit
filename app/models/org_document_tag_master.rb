# == Schema Information
#
# Table name: org_document_tag_masters
# Database name: document
#
#  id         :string(255)      not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  parent_id  :string(255)      default("NEYO"), not null
#
# Indexes
#
#  index_org_document_tag_masters_on_lower_id   (lower((id)::text)) UNIQUE
#  index_org_document_tag_masters_on_parent_id  (parent_id)
#
# Foreign Keys
#
#  fk_rails_...  (parent_id => org_document_tag_masters.id)
#

# frozen_string_literal: true

class OrgDocumentTagMaster < DocumentRecord
  include StringPrimaryKey
  include Treeable

  belongs_to :parent,
             class_name: "OrgDocumentTagMaster",
             inverse_of: :children,
             optional: true
  has_many :children,
           class_name: "OrgDocumentTagMaster",
           foreign_key: :parent_id,
           inverse_of: :parent,
           dependent: :restrict_with_error
  has_many :org_document_tags, dependent: :restrict_with_error
  has_many :org_documents, through: :org_document_tags
  validates :id, uniqueness: { case_sensitive: false }

  self.primary_key = "id"

  attribute :parent_id, default: "NEYO"

  validates :parent_id, presence: true, length: { maximum: 255 }

  def name
    I18n.t("org_document_tags.%{id}", id: id)
  end

  def root?
    parent_id == "NEYO"
  end
end
