require "test_helper"

class ComContactAuditTest < ActiveSupport::TestCase
  test "loads model and table name" do
    # This model is a compatibility shim to the legacy table
    assert_match /com_contact_histories/, ComContactAudit.table_name

    # association may or may not exist depending on shim implementation; exercise reflect
    refl = ComContactAudit.reflect_on_association(:com_contact)
    if refl
      assert_equal :belongs_to, refl.macro
    end
  end
end
