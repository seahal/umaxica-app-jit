require "test_helper"

class OrgDocumentAuditTest < ActiveSupport::TestCase
  test "loads model and associations" do
    assert_equal "org_document_audits", OrgDocumentAudit.table_name

    refl = OrgDocumentAudit.reflect_on_association(:org_document)

    assert_not_nil refl, "expected belongs_to :org_document association"
    assert_equal :belongs_to, refl.macro
  end
end
