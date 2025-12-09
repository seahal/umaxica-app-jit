require "test_helper"

class ComDocumentAuditTest < ActiveSupport::TestCase
  test "loads model and associations" do
    assert_equal "com_document_audits", ComDocumentAudit.table_name

    refl = ComDocumentAudit.reflect_on_association(:com_document)

    assert_not_nil refl, "expected belongs_to :com_document association"
    assert_equal :belongs_to, refl.macro
  end
end
