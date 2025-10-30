# == Schema Information
#
# Table name: documents
#
#  id               :uuid             not null, primary key
#  description      :string
#  title            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  entity_status_id :string
#  parent_id        :binary
#  prev_id          :binary
#  staff_id         :binary
#  succ_id          :binary
#
require "test_helper"

class DocumentTest < ActiveSupport::TestCase
  setup do
    Document.create(id: "01", parent_id: nil, prev_id: nil, succ_id: nil, title: "TERM", description: "")
    Document.create(id: "10", parent_id: "01", prev_id: nil, succ_id: "11", title: "", description: "1")
    Document.create(id: "11", parent_id: "01", prev_id: "10", succ_id: nil, title: "", description: "2")
    Document.create(id: "00", parent_id: nil, prev_id: nil, succ_id: nil, title: "PRIVACY", description: "")
  end

  test "the truth" do
    skip "TODO: replace with meaningful document test or remove"
  end

  test "should inherit from BusinessesRecord" do
    assert_operator Document, :<, BusinessesRecord
  end

  test "should create document with title and description" do
    document = Document.create(
      title: "Test Document",
      description: "Test Description"
    )

    assert_predicate document, :persisted?
    assert_equal "Test Document", document.title
    assert_equal "Test Description", document.description
  end

  test "should encrypt title" do
    document = Document.create(
      title: "Secret Title",
      description: "Public Description"
    )
    raw_data = Document.connection.execute("SELECT title FROM documents WHERE id = '#{document.id}'").first
    assert_not_equal "Secret Title", raw_data["title"] if raw_data
  end

  test "should encrypt description" do
    document = Document.create(
      title: "Public Title",
      description: "Secret Description"
    )
    raw_data = Document.connection.execute("SELECT description FROM documents WHERE id = '#{document.id}'").first
    assert_not_equal "Secret Description", raw_data["description"] if raw_data
  end

  test "should update document title" do
    document = Document.create(title: "Original Title", description: "Description")
    document.update(title: "Updated Title")

    assert_equal "Updated Title", document.reload.title
  end

  test "should update document description" do
    document = Document.create(title: "Title", description: "Original Description")
    document.update(description: "Updated Description")

    assert_equal "Updated Description", document.reload.description
  end

  test "should allow nil title" do
    document = Document.create(title: nil, description: "Description")

    assert_predicate document, :persisted?
    assert_nil document.title
  end

  test "should allow nil description" do
    document = Document.create(title: "Title", description: nil)

    assert_predicate document, :persisted?
    assert_nil document.description
  end
end
