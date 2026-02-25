# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: org_document_behaviors
# Database name: behavior
#
#  id           :bigint           not null, primary key
#  actor_type   :string
#  expires_at   :datetime
#  occurred_at  :datetime
#  subject_type :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  actor_id     :bigint
#  event_id     :bigint           not null
#  level_id     :bigint           not null
#  subject_id   :bigint           not null
#
# Indexes
#
#  index_org_document_behaviors_on_actor_type_and_actor_id      (actor_type,actor_id)
#  index_org_document_behaviors_on_event_id                     (event_id)
#  index_org_document_behaviors_on_level_id                     (level_id)
#  index_org_document_behaviors_on_subject_id                   (subject_id)
#  index_org_document_behaviors_on_subject_type_and_subject_id  (subject_type,subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => org_document_behavior_events.id)
#  fk_rails_...  (level_id => org_document_behavior_levels.id)
#

require "test_helper"

class OrgDocumentBehaviorTest < ActiveSupport::TestCase
  fixtures :org_documents, :org_document_behavior_events, :org_document_behavior_levels
  test "loads model and associations" do
    assert_equal "org_document_behaviors", OrgDocumentBehavior.table_name

    refl = OrgDocumentBehavior.reflect_on_association(:org_document)

    assert_not_nil refl, "expected belongs_to :org_document association"
    assert_equal :belongs_to, refl.macro

    refl_level = OrgDocumentBehavior.reflect_on_association(:org_document_behavior_level)

    assert_not_nil refl_level, "expected belongs_to :org_document_behavior_level association"
    assert_equal :belongs_to, refl_level.macro
  end

  test "org_document helper method returns nil when subject_type is not OrgDocument" do
    audit = OrgDocumentBehavior.new(
      subject_id: 123,
      subject_type: "SomeOtherType",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
    )

    assert_nil audit.org_document
  end

  test "org_document helper method resolves when subject_type is OrgDocument" do
    doc = org_documents(:one)
    audit = OrgDocumentBehavior.new(
      subject_id: doc.id,
      subject_type: "OrgDocument",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
      event_id: org_document_behavior_events(:created).id,
      level_id: org_document_behavior_levels(:neyo).id,
    )

    assert_equal doc, audit.org_document
  end

  test "org_document= helper method sets subject_id and subject_type" do
    test_id = 123

    doc = OrgDocument.new
    doc.define_singleton_method(:id) { test_id }

    audit = OrgDocumentBehavior.new
    audit.org_document = doc

    assert_equal test_id, audit.subject_id
    assert_equal "OrgDocument", audit.subject_type
  end
end
