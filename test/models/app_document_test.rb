require "test_helper"

class AppDocumentTest < ActiveSupport::TestCase
  fixtures :app_document_statuses

  def setup
    @status = app_document_statuses(:ACTIVE)
    @app_document = AppDocument.create!(
      title: "Test Document",
      description: "A test document",
      app_document_status: @status
    )
  end

  test "AppDocument class exists" do
    assert_kind_of Class, AppDocument
  end

  test "AppDocument inherits from BusinessesRecord" do
    assert_operator AppDocument, :<, BusinessesRecord
  end

  test "belongs to app_document_status" do
    association = AppDocument.reflect_on_association(:app_document_status)

    assert_not_nil association
    assert_equal :belongs_to, association.macro
  end

  test "can be created with status" do
    assert_not_nil @app_document
    assert_equal @status.id, @app_document.app_document_status_id
  end

  test "app_document_status association loads status correctly" do
    assert_equal @status, @app_document.app_document_status
    assert_equal "ACTIVE", @app_document.app_document_status.id
  end

  test "title and description are encrypted" do
    doc = AppDocument.create!(
      title: "Secret Title",
      description: "Secret Description",
      app_document_status: @status
    )

    reloaded = AppDocument.find(doc.id)

    assert_equal "Secret Title", reloaded.title
    assert_equal "Secret Description", reloaded.description
  end

  test "app_document_status_id can be nil" do
    doc = AppDocument.create!(title: "No Status Document")

    assert_nil doc.app_document_status_id
    assert_nil doc.app_document_status
  end
end
