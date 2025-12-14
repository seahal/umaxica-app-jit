require "test_helper"

class ComDocumentStatusTest < ActiveSupport::TestCase
  include StatusModelTestHelper

  fixtures :com_document_statuses

  def setup
    @model_class = ComDocumentStatus
    @valid_id = "ACTIVE"
    @subject = @model_class.new(id: @valid_id)
    @status = com_document_statuses(:ACTIVE)
  end

  test "inherits from BusinessesRecord" do
    assert_operator ComDocumentStatus, :<, BusinessesRecord
  end

  test "has many com_documents" do
    association = ComDocumentStatus.reflect_on_association(:com_documents)

    assert_not_nil association
    assert_equal :has_many, association.macro
  end

  test "id is required" do
    status = ComDocumentStatus.new(id: nil)

    assert_not status.valid?
    assert_not_empty status.errors[:id]
  end

  test "id must be unique" do
    status = ComDocumentStatus.new(id: "ACTIVE")

    assert_not status.valid?
    assert_not_empty status.errors[:id]
  end

  test "id must have maximum length of 255" do
    status = ComDocumentStatus.new(id: "A" * 256)

    assert_not status.valid?
    assert_not_empty status.errors[:id]
  end

  test "id can have maximum length of 255" do
    long_id = "A" * 255
    status = ComDocumentStatus.create!(id: long_id)

    assert_predicate status, :valid?
    assert_equal 255, status.id.length
  end

  test "has timestamps" do
    assert_not_nil @status.created_at
    assert_not_nil @status.updated_at
  end

  test "can load draft status from fixtures" do
    draft = com_document_statuses(:DRAFT)

    assert_not_nil draft
    assert_equal "DRAFT", draft.id
  end

  test "can load archived status from fixtures" do
    archived = com_document_statuses(:ARCHIVED)

    assert_not_nil archived
    assert_equal "ARCHIVED", archived.id
  end
end
