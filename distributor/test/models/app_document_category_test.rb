# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: app_document_categories
# Database name: publication
#
#  id                              :bigint           not null, primary key
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  app_document_category_master_id :bigint           default(0), not null
#  app_document_id                 :bigint           not null
#
# Indexes
#
#  idx_on_app_document_category_master_id_018a74a5ab  (app_document_category_master_id)
#  index_app_document_categories_on_app_document_id   (app_document_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (app_document_category_master_id => app_document_category_masters.id)
#  fk_rails_...  (app_document_id => app_documents.id)
#

require "test_helper"

class AppDocumentCategoryTest < ActiveSupport::TestCase
  def setup
    @app_document = app_documents(:one)
    @category_master = app_document_category_masters(:one)
  end

  test "should be valid with app_document and category_master" do
    record = AppDocumentCategory.new(
      app_document: @app_document,
      app_document_category_master: @category_master,
    )

    assert_predicate record, :valid?
  end

  test "should require app_document" do
    record = AppDocumentCategory.new(
      app_document_category_master: @category_master,
    )

    assert_not record.valid?
    assert_not_empty record.errors[:app_document]
  end

  test "should require app_document_category_master" do
    record = AppDocumentCategory.new(
      app_document: @app_document,
    )

    assert_not record.valid?
    assert_not_empty record.errors[:app_document_category_master_id]
  end

  test "app_document_id must be unique" do
    AppDocumentCategory.create!(
      app_document: @app_document,
      app_document_category_master: @category_master,
    )

    other_master = app_document_category_masters(:two)
    duplicate = AppDocumentCategory.new(
      app_document: @app_document,
      app_document_category_master: other_master,
    )

    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:app_document_id]
  end

  test "same category_master with different app_document is allowed" do
    AppDocumentCategory.create!(
      app_document: @app_document,
      app_document_category_master: @category_master,
    )

    other_document = app_documents(:two)
    different_document = AppDocumentCategory.new(
      app_document: other_document,
      app_document_category_master: @category_master,
    )

    assert_predicate different_document, :valid?
  end

  test "belongs to app_document" do
    record = AppDocumentCategory.create!(
      app_document: @app_document,
      app_document_category_master: @category_master,
    )

    assert_equal @app_document, record.app_document
  end

  test "belongs to app_document_category_master" do
    record = AppDocumentCategory.create!(
      app_document: @app_document,
      app_document_category_master: @category_master,
    )

    assert_equal @category_master, record.app_document_category_master
  end
end
