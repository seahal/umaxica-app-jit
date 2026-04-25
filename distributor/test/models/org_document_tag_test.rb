# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: org_document_tags
# Database name: publication
#
#  id                         :bigint           not null, primary key
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  org_document_id            :bigint           not null
#  org_document_tag_master_id :bigint           default(0), not null
#
# Indexes
#
#  idx_on_org_document_tag_master_id_org_document_id_048a2b05e4  (org_document_tag_master_id,org_document_id) UNIQUE
#  index_org_document_tags_on_org_document_id                    (org_document_id)
#
# Foreign Keys
#
#  fk_rails_...  (org_document_id => org_documents.id)
#  fk_rails_...  (org_document_tag_master_id => org_document_tag_masters.id)
#
require "test_helper"

class OrgDocumentTagTest < ActiveSupport::TestCase
  def setup
    @org_document = org_documents(:one)
    @tag_master = org_document_tag_masters(:nothing)
  end

  test "is valid with org_document and tag_master" do
    record = OrgDocumentTag.new(
      org_document: @org_document,
      org_document_tag_master: @tag_master,
    )

    assert_predicate record, :valid?
  end

  test "requires org_document" do
    record = OrgDocumentTag.new(org_document_tag_master: @tag_master)

    assert_not record.valid?
    assert_not_empty record.errors[:org_document]
  end

  test "org_document and tag_master combination must be unique" do
    OrgDocumentTag.create!(
      org_document: @org_document,
      org_document_tag_master: @tag_master,
    )

    duplicate = OrgDocumentTag.new(
      org_document: @org_document,
      org_document_tag_master: @tag_master,
    )

    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:org_document_tag_master_id]
  end

  test "different org_document with same tag_master is allowed" do
    other_document = org_documents(:two)
    record = OrgDocumentTag.new(
      org_document: other_document,
      org_document_tag_master: @tag_master,
    )

    assert_predicate record, :valid?
  end
end
