require "test_helper"

class AppDocumentAuditTest < ActiveSupport::TestCase
  test "loads model and associations" do
    assert_equal "app_document_audits", AppDocumentAudit.table_name

    refl = AppDocumentAudit.reflect_on_association(:app_document)

    assert_not_nil refl, "expected belongs_to :app_document association"
    assert_equal :belongs_to, refl.macro

    refl_level = AppDocumentAudit.reflect_on_association(:app_document_audit_level)
    assert_not_nil refl_level, "expected belongs_to :app_document_audit_level association"
    assert_equal :belongs_to, refl_level.macro
  end
end
