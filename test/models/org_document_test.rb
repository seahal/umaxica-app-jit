require "test_helper"

class OrgDocumentTest < ActiveSupport::TestCase
  fixtures :org_document_statuses

  def setup
    @status = org_document_statuses(:ACTIVE)
    @org_document = OrgDocument.create!(
      title: "Test Document",
      description: "A test document",
      org_document_status: @status
    )
  end

  test "OrgDocument class exists" do
    assert_kind_of Class, OrgDocument
  end

  test "OrgDocument inherits from BusinessesRecord" do
    assert_operator OrgDocument, :<, BusinessesRecord
  end

  test "belongs to org_document_status" do
    association = OrgDocument.reflect_on_association(:org_document_status)

    assert_not_nil association
    assert_equal :belongs_to, association.macro
  end

  test "can be created with status" do
    assert_not_nil @org_document
    assert_equal @status.id, @org_document.org_document_status_id
  end

  test "org_document_status association loads status correctly" do
    assert_equal @status, @org_document.org_document_status
    assert_equal "ACTIVE", @org_document.org_document_status.id
  end

  test "title and description are encrypted" do
    doc = OrgDocument.create!(
      title: "Secret Title",
      description: "Secret Description",
      org_document_status: @status
    )

    reloaded = OrgDocument.find(doc.id)

    assert_equal "Secret Title", reloaded.title
    assert_equal "Secret Description", reloaded.description
  end

  test "org_document_status_id can be nil" do
    doc = OrgDocument.create!(title: "No Status Document")

    assert_nil doc.org_document_status_id
    assert_nil doc.org_document_status
  end
end
