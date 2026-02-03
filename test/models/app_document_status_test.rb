# frozen_string_literal: true

# == Schema Information
#
# Table name: app_document_statuses
# Database name: document
#
#  id :bigint           not null, primary key
#

require "test_helper"

class AppDocumentStatusTest < ActiveSupport::TestCase
  fixtures :app_document_statuses

  def setup
    @model_class = AppDocumentStatus
    @valid_id = AppDocumentStatus::ACTIVE
    @subject = @model_class.new(id: @valid_id)
    @status = AppDocumentStatus.find(AppDocumentStatus::ACTIVE)
  end

  test "inherits from DocumentRecord" do
    assert_operator AppDocumentStatus, :<, DocumentRecord
  end

  test "id is numeric" do
    assert_kind_of Integer, @status.id
  end

  test "can load draft status from fixtures" do
    draft = AppDocumentStatus.find(AppDocumentStatus::DRAFT)

    assert_not_nil draft
    assert_equal AppDocumentStatus::DRAFT, draft.id
  end

  test "can load archived status from fixtures" do
    archived = AppDocumentStatus.find(AppDocumentStatus::ARCHIVED)

    assert_not_nil archived
    assert_equal AppDocumentStatus::ARCHIVED, archived.id
  end
end
