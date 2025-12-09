require "test_helper"

class AppDocumentAuditTest < ActiveSupport::TestCase
  test "loads model and associations" do
    assert_equal "app_document_audits", AppDocumentAudit.table_name

    refl = AppDocumentAudit.reflect_on_association(:app_document)

    assert_not_nil refl, "expected belongs_to :app_document association"
    assert_equal :belongs_to, refl.macro
  end
end
