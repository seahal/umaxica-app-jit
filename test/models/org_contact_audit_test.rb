# == Schema Information
#
# Table name: org_contact_histories
#
#  id             :uuid             not null, primary key
#  actor_id       :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  actor_type     :string           default(""), not null
#  created_at     :datetime         not null
#  event_id       :string(255)      default("NONE"), not null
#  org_contact_id :uuid             not null
#  parent_id      :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  position       :integer          default(0), not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_org_contact_histories_on_actor_type_and_actor_id  (actor_type,actor_id)
#  index_org_contact_histories_on_org_contact_id           (org_contact_id)
#  index_org_contact_histories_on_parent_id                (parent_id)
#

require "test_helper"

class OrgContactAuditTest < ActiveSupport::TestCase
  test "loads model and table name" do
    assert_equal "org_contact_histories", OrgContactAudit.table_name
  end

  test "associations" do
    assert_not_nil OrgContactAudit.reflect_on_association(:org_contact)
    assert_not_nil OrgContactAudit.reflect_on_association(:actor)
    assert_not_nil OrgContactAudit.reflect_on_association(:org_contact_audit_event)
  end
end
