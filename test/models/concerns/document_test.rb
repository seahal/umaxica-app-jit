# typed: false
# frozen_string_literal: true

require "test_helper"

class DocumentTest < ActiveSupport::TestCase
  test "defines supported response modes" do
    expected_modes = %w(html text pdf redirect)

    assert_equal expected_modes, AppDocument.response_modes.keys
    assert_equal expected_modes, OrgDocument.response_modes.keys
  end

  test "generates revision_key before validation" do
    [AppDocument, OrgDocument].each do |klass|
      document = klass.new(document_attributes_for(klass).merge(revision_key: nil))

      assert_predicate document, :valid?
      assert_predicate document.revision_key, :present?
    end
  end

  private

  def document_attributes_for(klass)
    status_id =
      if klass == AppDocument
        AppDocumentStatus::NOTHING
      else
        OrgDocumentStatus::NOTHING
      end

    {
      permalink: "document_concern_#{klass.name.demodulize.underscore}",
      response_mode: "html",
      published_at: 1.hour.ago,
      expires_at: 1.hour.from_now,
      position: 0,
      status_id: status_id,
    }
  end
end
