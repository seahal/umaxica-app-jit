# == Schema Information
#
# Table name: com_document_audits
#
#  id              :uuid             not null, primary key
#  actor_id        :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  actor_type      :string           default(""), not null
#  com_document_id :uuid             not null
#  created_at      :datetime         not null
#  current_value   :text             default(""), not null
#  event_id        :string(255)      default(""), not null
#  ip_address      :string           default(""), not null
#  level_id        :string           default("NONE"), not null
#  previous_value  :text             default(""), not null
#  timestamp       :datetime         default("-infinity"), not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_com_document_audits_on_actor_type_and_actor_id  (actor_type,actor_id)
#  index_com_document_audits_on_com_document_id          (com_document_id)
#  index_com_document_audits_on_level_id                 (level_id)
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
end
