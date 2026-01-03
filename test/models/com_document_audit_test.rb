# frozen_string_literal: true

# == Schema Information
#
# Table name: com_document_audits
#
#  id             :uuid             not null, primary key
#  subject_id     :string           not null
#  subject_type   :text             not null
#  actor_id       :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  actor_type     :text             default(""), not null
#  event_id       :string(255)      default("NEYO"), not null
#  level_id       :string(255)      default("NEYO"), not null
#  occurred_at    :datetime         not null
#  expires_at     :datetime         not null
#  ip_address     :inet             default("0.0.0.0"), not null
#  context        :jsonb            default("{}"), not null
#  previous_value :text             default(""), not null
#  current_value  :text             default(""), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  idx_on_subject_type_subject_id_occurred_at_c40361e81b  (subject_type,subject_id,occurred_at)
#  index_com_document_audits_on_actor_id_and_occurred_at  (actor_id,occurred_at)
#  index_com_document_audits_on_event_id                  (event_id)
#  index_com_document_audits_on_expires_at                (expires_at)
#  index_com_document_audits_on_level_id                  (level_id)
#  index_com_document_audits_on_occurred_at               (occurred_at)
#  index_com_document_audits_on_subject_id                (subject_id)
#

require "test_helper"

class ComDocumentAuditTest < ActiveSupport::TestCase
  test "loads model and associations" do
    assert_equal "com_document_audits", ComDocumentAudit.table_name

    refl = ComDocumentAudit.reflect_on_association(:com_document)

    assert_not_nil refl, "expected belongs_to :com_document association"
    assert_equal :belongs_to, refl.macro

    refl_level = ComDocumentAudit.reflect_on_association(:com_document_audit_level)
    assert_not_nil refl_level, "expected belongs_to :com_document_audit_level association"
    assert_equal :belongs_to, refl_level.macro
  end

  test "com_document helper method returns nil when subject_type is not ComDocument" do
    audit = ComDocumentAudit.new(
      subject_id: "123",
      subject_type: "SomeOtherType",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
    )
    assert_nil audit.com_document
  end

  test "com_document= helper method sets subject_id and subject_type" do
    test_uuid = SecureRandom.uuid

    doc = ComDocument.new
    doc.define_singleton_method(:id) { test_uuid }

    audit = ComDocumentAudit.new
    audit.com_document = doc

    assert_equal test_uuid, audit.subject_id
    assert_equal "ComDocument", audit.subject_type
  end
end
