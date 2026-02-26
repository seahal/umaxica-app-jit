# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: app_document_behaviors
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
#  index_app_document_behaviors_on_actor_type_and_actor_id      (actor_type,actor_id)
#  index_app_document_behaviors_on_event_id                     (event_id)
#  index_app_document_behaviors_on_level_id                     (level_id)
#  index_app_document_behaviors_on_subject_id                   (subject_id)
#  index_app_document_behaviors_on_subject_type_and_subject_id  (subject_type,subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => app_document_behavior_events.id)
#  fk_rails_...  (level_id => app_document_behavior_levels.id)
#

require "test_helper"

class AppDocumentBehaviorTest < ActiveSupport::TestCase
  test "loads model and associations" do
    assert_equal "app_document_behaviors", AppDocumentBehavior.table_name

    refl = AppDocumentBehavior.reflect_on_association(:app_document)

    assert_not_nil refl, "expected belongs_to :app_document association"
    assert_equal :belongs_to, refl.macro

    refl_level = AppDocumentBehavior.reflect_on_association(:app_document_behavior_level)

    assert_not_nil refl_level, "expected belongs_to :app_document_behavior_level association"
    assert_equal :belongs_to, refl_level.macro
  end

  test "app_document helper method returns nil when subject_type is not AppDocument" do
    audit = AppDocumentBehavior.new(
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

    audit = AppDocumentBehavior.new
    audit.app_document = doc

    assert_equal test_id, audit.subject_id
    assert_equal "AppDocument", audit.subject_type
  end
  test "app_document helper method returns document when subject_type is AppDocument" do
    AppDocumentBehaviorEvent.find_or_create_by!(id: AppDocumentBehaviorEvent::CREATED)
    AppDocumentBehaviorLevel.find_or_create_by!(id: AppDocumentBehaviorLevel::NOTHING)
    doc = AppDocument.create!(
      status_id: AppDocumentStatus::NOTHING,
      slug_id: "test-doc-#{SecureRandom.hex(4)}",
      permalink: "test_perm_#{SecureRandom.hex(4)}",
      revision_key: "rev_#{SecureRandom.hex(4)}",
      published_at: Time.current,
      expires_at: 1.year.from_now,
    )
    audit = AppDocumentBehavior.create!(
      subject_id: doc.id,
      subject_type: "AppDocument",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
      event_id: AppDocumentBehaviorEvent::CREATED,
      level_id: AppDocumentBehaviorLevel::NOTHING,
    )

    assert_equal doc, audit.app_document
  end
end
