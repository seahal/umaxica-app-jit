# == Schema Information
#
# Table name: app_contact_histories
#
#  id             :uuid             not null, primary key
#  actor_id       :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  actor_type     :string           default(""), not null
#  app_contact_id :uuid             not null
#  created_at     :datetime         not null
#  event_id       :string(255)      default("NONE"), not null
#  parent_id      :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  position       :integer          default(0), not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_app_contact_histories_on_actor_type_and_actor_id  (actor_type,actor_id)
#  index_app_contact_histories_on_app_contact_id           (app_contact_id)
#  index_app_contact_histories_on_parent_id                (parent_id)
#

require "test_helper"

class AppContactAuditTest < ActiveSupport::TestCase
  test "loads model and table name" do
    assert_equal "app_contact_histories", AppContactAudit.table_name
  end

  test "associations" do
    assert_not_nil AppContactAudit.reflect_on_association(:app_contact)
    assert_not_nil AppContactAudit.reflect_on_association(:actor)
    assert_not_nil AppContactAudit.reflect_on_association(:app_contact_audit_event)
  end
end
