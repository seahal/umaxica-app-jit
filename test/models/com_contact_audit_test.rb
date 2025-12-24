# == Schema Information
#
# Table name: com_contact_audits
#
#  id             :uuid             not null, primary key
#  actor_id       :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  actor_type     :string           default(""), not null
#  com_contact_id :uuid             not null
#  created_at     :datetime         not null
#  event_id       :string(255)      default("NONE"), not null
#  parent_id      :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  position       :integer          default(0), not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_com_contact_audits_on_actor_type_and_actor_id  (actor_type,actor_id)
#  index_com_contact_audits_on_com_contact_id           (com_contact_id)
#

require "test_helper"

class ComContactAuditTest < ActiveSupport::TestCase
  test "loads model and table name" do
    assert_equal "com_contact_audits", ComContactAudit.table_name
  end

  test "associations" do
    assert_not_nil ComContactAudit.reflect_on_association(:com_contact)
    assert_not_nil ComContactAudit.reflect_on_association(:actor)
    assert_not_nil ComContactAudit.reflect_on_association(:com_contact_audit_event)
  end
end
