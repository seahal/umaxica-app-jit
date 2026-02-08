# frozen_string_literal: true

# == Schema Information
#
# Table name: app_document_audits
# Database name: activity
#
#  id             :bigint           not null, primary key
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
#  actor_id       :bigint           default(0), not null
#  event_id       :bigint           default(0), not null
#  level_id       :bigint           default(0), not null
#  subject_id     :bigint           not null
#
# Indexes
#
#  idx_on_subject_type_subject_id_occurred_at_cf1fa79ee4  (subject_type,subject_id,occurred_at)
#  index_app_document_audits_on_actor_id_and_occurred_at  (actor_id,occurred_at)
#  index_app_document_audits_on_event_id                  (event_id)
#  index_app_document_audits_on_expires_at                (expires_at)
#  index_app_document_audits_on_level_id                  (level_id)
#  index_app_document_audits_on_occurred_at               (occurred_at)
#  index_app_document_audits_on_subject_id                (subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => app_document_audit_events.id)
#  fk_rails_...  (level_id => app_document_audit_levels.id)
#

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

  test "app_document helper method returns nil when subject_type is not AppDocument" do
    audit = AppDocumentAudit.new(
      subject_id: 123,
      subject_type: "SomeOtherType",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
    )
    assert_nil audit.app_document
  end

  test "app_document= helper method sets subject_id and subject_type" do
    test_id = 123

    # Create a mock document object with an ID
    doc = AppDocument.new
    doc.define_singleton_method(:id) { test_id }

    audit = AppDocumentAudit.new
    audit.app_document = doc

    assert_equal test_id, audit.subject_id
    assert_equal "AppDocument", audit.subject_type
  end
  test "app_document helper method returns document when subject_type is AppDocument" do
    AppDocumentAuditEvent.find_or_create_by!(id: AppDocumentAuditEvent::CREATED)
    AppDocumentAuditLevel.find_or_create_by!(id: AppDocumentAuditLevel::NEYO)
    doc = AppDocument.create!(
      status_id: AppDocumentStatus::NEYO,
      slug_id: "test-doc-#{SecureRandom.hex(4)}",
      permalink: "test_perm_#{SecureRandom.hex(4)}",
      revision_key: "rev_#{SecureRandom.hex(4)}",
      published_at: Time.current,
      expires_at: 1.year.from_now,
    )
    audit = AppDocumentAudit.create!(
      subject_id: doc.id,
      subject_type: "AppDocument",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
      event_id: AppDocumentAuditEvent::CREATED,
      level_id: AppDocumentAuditLevel::NEYO,
    )

    assert_equal doc, audit.app_document
  end
end
