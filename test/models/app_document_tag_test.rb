# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: app_document_tags
# Database name: publication
#
#  id                         :bigint           not null, primary key
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  app_document_id            :bigint           not null
#  app_document_tag_master_id :bigint           default(0), not null
#
# Indexes
#
#  idx_on_app_document_tag_master_id_app_document_id_75ee747154  (app_document_tag_master_id,app_document_id) UNIQUE
#  index_app_document_tags_on_app_document_id                    (app_document_id)
#
# Foreign Keys
#
#  fk_rails_...  (app_document_id => app_documents.id)
#  fk_rails_...  (app_document_tag_master_id => app_document_tag_masters.id)
#
require "test_helper"

class AppDocumentTagTest < ActiveSupport::TestCase
  def setup
    @app_document = app_documents(:one)
    @tag_master = app_document_tag_masters(:nothing)
  end

  test "is valid with app_document and tag_master" do
    record = AppDocumentTag.new(
      app_document: @app_document,
      app_document_tag_master: @tag_master,
    )

    assert_predicate record, :valid?
  end

  test "requires app_document" do
    record = AppDocumentTag.new(app_document_tag_master: @tag_master)

    assert_not record.valid?
    assert_not_empty record.errors[:app_document]
  end

  test "app_document and tag_master combination must be unique" do
    AppDocumentTag.create!(
      app_document: @app_document,
      app_document_tag_master: @tag_master,
    )

    duplicate = AppDocumentTag.new(
      app_document: @app_document,
      app_document_tag_master: @tag_master,
    )

    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:app_document_tag_master_id]
  end

  test "different app_document with same tag_master is allowed" do
    other_document = app_documents(:two)
    record = AppDocumentTag.new(
      app_document: other_document,
      app_document_tag_master: @tag_master,
    )

    assert_predicate record, :valid?
  end
end
