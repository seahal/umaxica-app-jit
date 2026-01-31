# == Schema Information
#
# Table name: app_document_tag_masters
# Database name: document
#
#  id        :integer          default(0), not null, primary key
#  parent_id :integer          default(0), not null
#
# Indexes
#
#  index_app_document_tag_masters_on_parent_id  (parent_id)
#
# Foreign Keys
#
#  fk_rails_...  (parent_id => app_document_tag_masters.id)
#

# frozen_string_literal: true

class AppDocumentTagMaster < DocumentRecord
  include StringPrimaryKey
  include Treeable

  belongs_to :parent,
             class_name: "AppDocumentTagMaster",
             inverse_of: :children,
             optional: true
  has_many :children,
           class_name: "AppDocumentTagMaster",
           foreign_key: :parent_id,
           inverse_of: :parent,
           dependent: :restrict_with_error
  has_many :app_document_tags, dependent: :restrict_with_error
  has_many :app_documents, through: :app_document_tags
  validates :id, uniqueness: { case_sensitive: false }

  self.primary_key = "id"

  attribute :parent_id, default: "NEYO"

  validates :parent_id, presence: true, length: { maximum: 255 }

  def name
    I18n.t("app_document_tags.%{id}", id: id)
  end

  def root?
    parent_id == "NEYO"
  end
end
