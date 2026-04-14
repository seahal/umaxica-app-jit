# typed: false
# frozen_string_literal: true

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
require "test_helper"

class ComDocumentTagTest < ActiveSupport::TestCase
  def setup
    @com_document = com_documents(:one)
    @tag_master = com_document_tag_masters(:nothing)
  end

  test "is valid with com_document and tag_master" do
    record = ComDocumentTag.new(
      com_document: @com_document,
      com_document_tag_master: @tag_master,
    )

    assert_predicate record, :valid?
  end

  test "requires com_document" do
    record = ComDocumentTag.new(com_document_tag_master: @tag_master)

    assert_not record.valid?
    assert_not_empty record.errors[:com_document]
  end

  test "com_document and tag_master combination must be unique" do
    ComDocumentTag.create!(
      com_document: @com_document,
      com_document_tag_master: @tag_master,
    )

    duplicate = ComDocumentTag.new(
      com_document: @com_document,
      com_document_tag_master: @tag_master,
    )

    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:com_document_tag_master_id]
  end

  test "different com_document with same tag_master is allowed" do
    other_document = com_documents(:two)
    record = ComDocumentTag.new(
      com_document: other_document,
      com_document_tag_master: @tag_master,
    )

    assert_predicate record, :valid?
  end
end
