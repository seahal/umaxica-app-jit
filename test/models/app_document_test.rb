# == Schema Information
#
# Table name: app_documents
#
#  id                     :uuid             not null, primary key
#  app_document_status_id :string(255)      default(""), not null
#  created_at             :datetime         not null
#  description            :string           default(""), not null
#  parent_id              :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  prev_id                :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  public_id              :string(21)       default(""), not null
#  staff_id               :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  succ_id                :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  title                  :string           default(""), not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_app_documents_on_app_document_status_id  (app_document_status_id)
#  index_app_documents_on_parent_id               (parent_id)
#  index_app_documents_on_prev_id                 (prev_id)
#  index_app_documents_on_public_id               (public_id)
#  index_app_documents_on_staff_id                (staff_id)
#  index_app_documents_on_succ_id                 (succ_id)
#

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

  test "app_document_status_id defaults to empty string" do
    doc = AppDocument.create!(title: "No Status Document")

    assert_equal "", doc.app_document_status_id
    assert_nil doc.app_document_status
  end
end
