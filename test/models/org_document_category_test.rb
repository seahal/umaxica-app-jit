# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: org_document_categories
# Database name: publication
#
#  id                              :bigint           not null, primary key
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  org_document_category_master_id :bigint           default(0), not null
#  org_document_id                 :bigint           not null
#
# Indexes
#
#  idx_on_org_document_category_master_id_0d3d809e93  (org_document_category_master_id)
#  index_org_document_categories_on_org_document_id   (org_document_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (org_document_category_master_id => org_document_category_masters.id)
#  fk_rails_...  (org_document_id => org_documents.id)
#
require "test_helper"

class OrgDocumentCategoryTest < ActiveSupport::TestCase
  def setup
    @org_document = org_documents(:one)
    @category_master = org_document_category_masters(:nothing)
  end

  test "is valid with org_document and category_master" do
    record = OrgDocumentCategory.new(
      org_document: @org_document,
      org_document_category_master: @category_master,
    )

    assert_predicate record, :valid?
  end

  test "requires org_document" do
    record = OrgDocumentCategory.new(org_document_category_master: @category_master)

    assert_not record.valid?
    assert_not_empty record.errors[:org_document]
  end

  test "org_document must be unique" do
    OrgDocumentCategory.create!(
      org_document: @org_document,
      org_document_category_master: @category_master,
    )

    duplicate = OrgDocumentCategory.new(
      org_document: @org_document,
      org_document_category_master: @category_master,
    )

    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:org_document_id]
  end

  test "different org_document with same category_master is allowed" do
    other_document = org_documents(:two)
    record = OrgDocumentCategory.new(
      org_document: other_document,
      org_document_category_master: @category_master,
    )

    assert_predicate record, :valid?
  end
end
