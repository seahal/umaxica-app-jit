# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: com_document_categories
# Database name: publication
#
#  id                              :bigint           not null, primary key
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  com_document_category_master_id :bigint           default(0), not null
#  com_document_id                 :bigint           not null
#
# Indexes
#
#  idx_on_com_document_category_master_id_dc650e897c  (com_document_category_master_id)
#  index_com_document_categories_on_com_document_id   (com_document_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (com_document_category_master_id => com_document_category_masters.id)
#  fk_rails_...  (com_document_id => com_documents.id)
#
require "test_helper"

class ComDocumentCategoryTest < ActiveSupport::TestCase
  def setup
    @com_document = com_documents(:one)
    @category_master = com_document_category_masters(:nothing)
  end

  test "is valid with com_document and category_master" do
    record = ComDocumentCategory.new(
      com_document: @com_document,
      com_document_category_master: @category_master,
    )

    assert_predicate record, :valid?
  end

  test "requires com_document" do
    record = ComDocumentCategory.new(com_document_category_master: @category_master)

    assert_not record.valid?
    assert_not_empty record.errors[:com_document]
  end

  test "com_document must be unique" do
    ComDocumentCategory.create!(
      com_document: @com_document,
      com_document_category_master: @category_master,
    )

    duplicate = ComDocumentCategory.new(
      com_document: @com_document,
      com_document_category_master: @category_master,
    )

    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:com_document_id]
  end

  test "different com_document with same category_master is allowed" do
    other_document = com_documents(:two)
    record = ComDocumentCategory.new(
      com_document: other_document,
      com_document_category_master: @category_master,
    )

    assert_predicate record, :valid?
  end
end
