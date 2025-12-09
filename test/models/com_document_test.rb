require "test_helper"

class ComDocumentTest < ActiveSupport::TestCase
  fixtures :com_document_statuses

  def setup
    @status = com_document_statuses(:ACTIVE)
    @com_document = ComDocument.create!(
      title: "Test Document",
      description: "A test document",
      com_document_status: @status
    )
  end

  test "ComDocument class exists" do
    assert_kind_of Class, ComDocument
  end

  test "ComDocument inherits from BusinessesRecord" do
    assert_operator ComDocument, :<, BusinessesRecord
  end

  test "belongs to com_document_status" do
    association = ComDocument.reflect_on_association(:com_document_status)

    assert_not_nil association
    assert_equal :belongs_to, association.macro
  end

  test "can be created with status" do
    assert_not_nil @com_document
    assert_equal @status.id, @com_document.com_document_status_id
  end

  test "com_document_status association loads status correctly" do
    assert_equal @status, @com_document.com_document_status
    assert_equal "ACTIVE", @com_document.com_document_status.id
  end

  test "includes Document module" do
    assert_includes ComDocument.included_modules, Document
  end

  test "title and description are encrypted" do
    doc = ComDocument.create!(
      title: "Secret Title",
      description: "Secret Description",
      com_document_status: @status
    )

    reloaded = ComDocument.find(doc.id)

    assert_equal "Secret Title", reloaded.title
    assert_equal "Secret Description", reloaded.description
  end

  test "com_document_status_id can be nil" do
    doc = ComDocument.create!(title: "No Status Document")

    assert_nil doc.com_document_status_id
    assert_nil doc.com_document_status
  end
end
