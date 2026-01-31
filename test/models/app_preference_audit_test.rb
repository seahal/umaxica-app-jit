# == Schema Information
#
# Table name: app_preference_audits
# Database name: audit
#
#  id             :uuid             not null, primary key
#  actor_type     :text             default(""), not null
#  context        :jsonb            not null
#  current_value  :text             default(""), not null
#  expires_at     :datetime         not null
#  ip_address     :inet             default(#<IPAddr: IPv4:0.0.0.0/255.255.255.255>), not null
#  occurred_at    :datetime         not null
#  previous_value :text             default(""), not null
#  subject_type   :text             not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  actor_id       :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  event_id       :integer          default(0), not null
#  level_id       :integer          default(0), not null
#  subject_id     :string           not null
#
# Indexes
#
#  idx_on_subject_type_subject_id_occurred_at_app_pref      (subject_type,subject_id,occurred_at)
#  index_app_preference_audits_on_actor_id_and_occurred_at  (actor_id,occurred_at)
#  index_app_preference_audits_on_event_id                  (event_id)
#  index_app_preference_audits_on_expires_at                (expires_at)
#  index_app_preference_audits_on_level_id                  (level_id)
#  index_app_preference_audits_on_occurred_at               (occurred_at)
#  index_app_preference_audits_on_subject_id                (subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => app_preference_audit_events.id)
#  fk_rails_...  (level_id => app_preference_audit_levels.id)
#

# frozen_string_literal: true

require "test_helper"

class AppPreferenceAuditTest < ActiveSupport::TestCase
  setup do
    @audit = app_preference_audits(:one)
    @preference = app_preferences(:one)
  end

  test "belongs to app_preference" do
    assert_equal @preference, @audit.app_preference
  end

  test "can set app_preference" do
    new_pref = app_preferences(:two)
    @audit.app_preference = new_pref
    assert_equal new_pref.id.to_s, @audit.subject_id
    assert_equal "AppPreference", @audit.subject_type
    assert_equal new_pref, @audit.app_preference
  end

  test "belongs to app_preference_audit_level" do
    assert_equal app_preference_audit_levels(:info), @audit.app_preference_audit_level
  end

  test "belongs to app_preference_audit_event" do
    assert_equal app_preference_audit_events(:create_new_preference_token), @audit.app_preference_audit_event
  end

  test "validates presence of subject_id" do
    @audit.subject_id = nil
    assert_not @audit.valid?
    assert_includes @audit.errors[:subject_id], I18n.t("errors.messages.blank")
  end

  test "validates presence of subject_type" do
    @audit.subject_type = nil
    assert_not @audit.valid?
    assert_includes @audit.errors[:subject_type], I18n.t("errors.messages.blank")
  end

  test "validates length of event_id" do
    @audit.event_id = "A" * 256
    assert_not @audit.valid?
    assert_includes @audit.errors[:event_id], I18n.t("errors.messages.too_long", count: 255)
  end

  test "validates length of level_id" do
    @audit.level_id = "A" * 256
    assert_not @audit.valid?
    assert_includes @audit.errors[:level_id], I18n.t("errors.messages.too_long", count: 255)
  end

  test "app_preference helper method returns nil when subject_type is not AppPreference" do
    @audit.subject_type = "SomeOtherType"
    assert_nil @audit.app_preference
  end
end
