# frozen_string_literal: true

# == Schema Information
#
# Table name: com_document_statuses
# Database name: document
#
#  id :bigint           not null, primary key
#

require "test_helper"

class ComDocumentStatusTest < ActiveSupport::TestCase
  # fixtures :com_document_statuses

  def setup
    @model_class = ComDocumentStatus
    @valid_id = ComDocumentStatus::ACTIVE
    @subject = @model_class.new(id: @valid_id)
    @status = ComDocumentStatus.find(ComDocumentStatus::ACTIVE)
  end

  test "inherits from DocumentRecord" do
    assert_operator ComDocumentStatus, :<, DocumentRecord
  end

  test "id is numeric" do
    assert_kind_of Integer, @status.id
  end

  test "can load draft status from db" do
    draft = ComDocumentStatus.find(ComDocumentStatus::DRAFT)

    assert_not_nil draft
    assert_equal ComDocumentStatus::DRAFT, draft.id
  end

  test "can load archived status from db" do
    archived = ComDocumentStatus.find(ComDocumentStatus::ARCHIVED)

    assert_not_nil archived
    assert_equal ComDocumentStatus::ARCHIVED, archived.id
  end
end
