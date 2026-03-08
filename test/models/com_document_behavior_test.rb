# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: com_document_behaviors
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
#  index_com_document_behaviors_on_actor_type_and_actor_id      (actor_type,actor_id)
#  index_com_document_behaviors_on_event_id                     (event_id)
#  index_com_document_behaviors_on_level_id                     (level_id)
#  index_com_document_behaviors_on_subject_id                   (subject_id)
#  index_com_document_behaviors_on_subject_type_and_subject_id  (subject_type,subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => com_document_behavior_events.id)
#  fk_rails_...  (level_id => com_document_behavior_levels.id)
#

require "test_helper"

class ComDocumentBehaviorTest < ActiveSupport::TestCase
  fixtures :com_documents, :com_document_behavior_events, :com_document_behavior_levels
  test "loads model and associations" do
    assert_equal "com_document_behaviors", ComDocumentBehavior.table_name

    refl = ComDocumentBehavior.reflect_on_association(:com_document)

    assert_not_nil refl, "expected belongs_to :com_document association"
    assert_equal :belongs_to, refl.macro

    refl_level = ComDocumentBehavior.reflect_on_association(:com_document_behavior_level)

    assert_not_nil refl_level, "expected belongs_to :com_document_behavior_level association"
    assert_equal :belongs_to, refl_level.macro
  end

  test "com_document helper method returns nil when subject_type is not ComDocument" do
    audit = ComDocumentBehavior.new(
      subject_id: 123,
      subject_type: "SomeOtherType",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
    )

    assert_nil audit.com_document
  end

  test "com_document helper method resolves when subject_type is ComDocument" do
    doc = com_documents(:one)
    audit = ComDocumentBehavior.new(
      subject_id: doc.id,
      subject_type: "ComDocument",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
      event_id: com_document_behavior_events(:created).id,
      level_id: com_document_behavior_levels(:nothing).id,
    )

    assert_equal doc, audit.com_document
  end

  test "com_document= helper method sets subject_id and subject_type" do
    test_id = 123

    doc = ComDocument.new
    doc.define_singleton_method(:id) { test_id }

    audit = ComDocumentBehavior.new
    audit.com_document = doc

    assert_equal test_id, audit.subject_id
    assert_equal "ComDocument", audit.subject_type
  end
end
