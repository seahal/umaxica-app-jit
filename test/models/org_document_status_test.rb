# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: org_document_statuses
# Database name: document
#
#  id :bigint           not null, primary key
#

require "test_helper"

class OrgDocumentStatusTest < ActiveSupport::TestCase
  fixtures :org_document_statuses

  def setup
    @model_class = OrgDocumentStatus
    @valid_id = OrgDocumentStatus::ACTIVE
    @subject = @model_class.new(id: @valid_id)
    @status = OrgDocumentStatus.find(OrgDocumentStatus::ACTIVE)
  end

  test "inherits from DocumentRecord" do
    assert_operator OrgDocumentStatus, :<, DocumentRecord
  end

  test "id is numeric" do
    assert_kind_of Integer, @status.id
  end

  test "can load draft status from fixtures" do
    draft = OrgDocumentStatus.find(OrgDocumentStatus::DRAFT)

    assert_not_nil draft
    assert_equal OrgDocumentStatus::DRAFT, draft.id
  end

  test "can load archived status from fixtures" do
    archived = OrgDocumentStatus.find(OrgDocumentStatus::ARCHIVED)

    assert_not_nil archived
    assert_equal OrgDocumentStatus::ARCHIVED, archived.id
  end
end
