# frozen_string_literal: true

require "test_helper"

class DocumentVersionWriterTest < ActiveSupport::TestCase
  test "writes com document version" do
    doc = com_documents(:one)

    version = nil
    assert_difference "ComDocumentVersion.count", 1 do
      version = DocumentVersionWriter.write!(doc, attrs: { title: "Title", description: "Desc", body: "Body" })
    end

    assert_equal doc, version.com_document
    assert_equal "Title", version.title
    assert_equal "Desc", version.description
    assert_equal "Body", version.body
  end

  test "writes app document version" do
    doc = app_documents(:one)

    version = nil
    assert_difference "AppDocumentVersion.count", 1 do
      version = DocumentVersionWriter.write!(doc, attrs: { title: "Title", description: "Desc", body: "Body" })
    end

    assert_equal doc, version.app_document
    assert_equal "Title", version.title
  end

  test "writes org document version" do
    doc = org_documents(:one)

    version = nil
    assert_difference "OrgDocumentVersion.count", 1 do
      version = DocumentVersionWriter.write!(doc, attrs: { title: "Title", description: "Desc", body: "Body" })
    end

    assert_equal doc, version.org_document
    assert_equal "Title", version.title
  end
end
