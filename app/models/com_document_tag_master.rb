# typed: false
# == Schema Information
#
# Table name: com_document_tag_masters
# Database name: document
#
#  id        :bigint           not null, primary key
#  parent_id :bigint           not null
#
# Indexes
#
#  index_com_document_tag_masters_on_parent_id  (parent_id)
#
# Foreign Keys
#
#  fk_rails_...  (parent_id => com_document_tag_masters.id)
#

# frozen_string_literal: true

class ComDocumentTagMaster < DocumentRecord
  # Fixed IDs - do not modify these values
  NEYO = 1

  include Treeable

  belongs_to :parent,
             class_name: "ComDocumentTagMaster",
             inverse_of: :children,
             optional: true
  has_many :children,
           class_name: "ComDocumentTagMaster",
           foreign_key: :parent_id,
           inverse_of: :parent,
           dependent: :restrict_with_error
  has_many :com_document_tags, dependent: :restrict_with_error
  has_many :com_documents, through: :com_document_tags

  self.primary_key = "id"

  attribute :parent_id, default: 0

  validates :parent_id, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def self.tree_root_parent_value = 0

  def name
    I18n.t("com_document_tags.%{id}", id: id)
  end

  def root?
    parent_id.zero?
  end
end
