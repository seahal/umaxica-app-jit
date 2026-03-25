# typed: false
# frozen_string_literal: true

require "test_helper"

class DocumentVersionWriterTest < ActiveSupport::TestCase
  fixtures :com_documents, :app_documents, :org_documents, :users, :staffs

  test "writes com document version" do
    doc = com_documents(:one)

    version = nil
    assert_difference "ComDocumentVersion.count", 1 do
      version = DocumentVersionWriter.write!(
        doc,
        attrs: { title: "Title", description: "Desc", body: "Body" },
      )
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
      version = DocumentVersionWriter.write!(
        doc,
        attrs: { title: "Title", description: "Desc", body: "Body" },
      )
    end

    assert_equal doc, version.app_document
    assert_equal "Title", version.title
  end

  test "writes org document version" do
    doc = org_documents(:one)

    version = nil
    assert_difference "OrgDocumentVersion.count", 1 do
      version = DocumentVersionWriter.write!(
        doc,
        attrs: { title: "Title", description: "Desc", body: "Body" },
      )
    end

    assert_equal doc, version.org_document
    assert_equal "Title", version.title
  end

  test "raises ArgumentError for unsupported document type" do
    unsupported_doc = Struct.new(:class).new(Class.new)

    assert_raises(ArgumentError) do
      DocumentVersionWriter.write!(
        unsupported_doc,
        attrs: { title: "Title", description: "Desc", body: "Body" },
      )
    end
  end

  test "writes version with user editor" do
    doc = com_documents(:one)
    user = users(:one)

    version = DocumentVersionWriter.write!(
      doc,
      attrs: { title: "Title", description: "Desc", body: "Body" },
      editor: user,
    )

    assert_equal "User", version.edited_by_type
    assert_equal user.id, version.edited_by_id
  end

  test "writes version with staff editor" do
    doc = com_documents(:one)
    staff = staffs(:one)

    version = DocumentVersionWriter.write!(
      doc,
      attrs: { title: "Title", description: "Desc", body: "Body" },
      editor: staff,
    )

    assert_equal "Staff", version.edited_by_type
    assert_equal staff.id, version.edited_by_id
  end

  test "writes version with nil editor" do
    doc = com_documents(:one)

    version = DocumentVersionWriter.write!(
      doc,
      attrs: { title: "Title", description: "Desc", body: "Body" },
      editor: nil,
    )

    assert_nil version.edited_by_type
    assert_nil version.edited_by_id
  end
end
