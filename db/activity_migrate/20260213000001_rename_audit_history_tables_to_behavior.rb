# frozen_string_literal: true

class RenameAuditHistoryTablesToBehavior < ActiveRecord::Migration[8.2]
  TABLE_RENAMES = {
    app_contact_audit_events: :app_contact_behavior_events,
    app_contact_audit_levels: :app_contact_behavior_levels,
    app_contact_histories: :app_contact_behaviors,
    app_document_audit_events: :app_document_behavior_events,
    app_document_audit_levels: :app_document_behavior_levels,
    app_document_audits: :app_document_behaviors,
    app_timeline_audit_events: :app_timeline_behavior_events,
    app_timeline_audit_levels: :app_timeline_behavior_levels,
    app_timeline_audits: :app_timeline_behaviors,
    com_contact_audit_events: :com_contact_behavior_events,
    com_contact_audit_levels: :com_contact_behavior_levels,
    com_contact_audits: :com_contact_behaviors,
    com_document_audit_events: :com_document_behavior_events,
    com_document_audit_levels: :com_document_behavior_levels,
    com_document_audits: :com_document_behaviors,
    com_timeline_audit_events: :com_timeline_behavior_events,
    com_timeline_audit_levels: :com_timeline_behavior_levels,
    com_timeline_audits: :com_timeline_behaviors,
    org_contact_audit_events: :org_contact_behavior_events,
    org_contact_audit_levels: :org_contact_behavior_levels,
    org_contact_histories: :org_contact_behaviors,
    org_document_audit_events: :org_document_behavior_events,
    org_document_audit_levels: :org_document_behavior_levels,
    org_document_audits: :org_document_behaviors,
    org_timeline_audit_events: :org_timeline_behavior_events,
    org_timeline_audit_levels: :org_timeline_behavior_levels,
    org_timeline_audits: :org_timeline_behaviors,
  }.freeze

  INDEX_RENAMES = {
    index_app_contact_histories_on_actor_id_and_occurred_at: :index_app_contact_behaviors_on_actor_id_and_occurred_at,
    index_app_contact_histories_on_event_id: :index_app_contact_behaviors_on_event_id,
    index_app_contact_histories_on_expires_at: :index_app_contact_behaviors_on_expires_at,
    index_app_contact_histories_on_level_id: :index_app_contact_behaviors_on_level_id,
    index_app_contact_histories_on_occurred_at: :index_app_contact_behaviors_on_occurred_at,
    index_app_contact_histories_on_parent_id: :index_app_contact_behaviors_on_parent_id,
    index_app_document_audits_on_actor_id_and_occurred_at: :index_app_document_behaviors_on_actor_id_and_occurred_at,
    index_app_document_audits_on_event_id: :index_app_document_behaviors_on_event_id,
    index_app_document_audits_on_expires_at: :index_app_document_behaviors_on_expires_at,
    index_app_document_audits_on_level_id: :index_app_document_behaviors_on_level_id,
    index_app_document_audits_on_occurred_at: :index_app_document_behaviors_on_occurred_at,
    index_app_document_audits_on_subject_id: :index_app_document_behaviors_on_subject_id,
    index_app_timeline_audits_on_actor_id_and_occurred_at: :index_app_timeline_behaviors_on_actor_id_and_occurred_at,
    index_app_timeline_audits_on_event_id: :index_app_timeline_behaviors_on_event_id,
    index_app_timeline_audits_on_expires_at: :index_app_timeline_behaviors_on_expires_at,
    index_app_timeline_audits_on_level_id: :index_app_timeline_behaviors_on_level_id,
    index_app_timeline_audits_on_occurred_at: :index_app_timeline_behaviors_on_occurred_at,
    index_app_timeline_audits_on_subject_id: :index_app_timeline_behaviors_on_subject_id,
    index_com_contact_audits_on_actor_id_and_occurred_at: :index_com_contact_behaviors_on_actor_id_and_occurred_at,
    index_com_contact_audits_on_event_id: :index_com_contact_behaviors_on_event_id,
    index_com_contact_audits_on_expires_at: :index_com_contact_behaviors_on_expires_at,
    index_com_contact_audits_on_level_id: :index_com_contact_behaviors_on_level_id,
    index_com_contact_audits_on_occurred_at: :index_com_contact_behaviors_on_occurred_at,
    index_com_contact_audits_on_parent_id: :index_com_contact_behaviors_on_parent_id,
    index_com_document_audits_on_actor_id_and_occurred_at: :index_com_document_behaviors_on_actor_id_and_occurred_at,
    index_com_document_audits_on_event_id: :index_com_document_behaviors_on_event_id,
    index_com_document_audits_on_expires_at: :index_com_document_behaviors_on_expires_at,
    index_com_document_audits_on_level_id: :index_com_document_behaviors_on_level_id,
    index_com_document_audits_on_occurred_at: :index_com_document_behaviors_on_occurred_at,
    index_com_document_audits_on_subject_id: :index_com_document_behaviors_on_subject_id,
    index_com_timeline_audits_on_actor_id_and_occurred_at: :index_com_timeline_behaviors_on_actor_id_and_occurred_at,
    index_com_timeline_audits_on_event_id: :index_com_timeline_behaviors_on_event_id,
    index_com_timeline_audits_on_expires_at: :index_com_timeline_behaviors_on_expires_at,
    index_com_timeline_audits_on_level_id: :index_com_timeline_behaviors_on_level_id,
    index_com_timeline_audits_on_occurred_at: :index_com_timeline_behaviors_on_occurred_at,
    index_com_timeline_audits_on_subject_id: :index_com_timeline_behaviors_on_subject_id,
    index_org_contact_histories_on_actor_id_and_occurred_at: :index_org_contact_behaviors_on_actor_id_and_occurred_at,
    index_org_contact_histories_on_event_id: :index_org_contact_behaviors_on_event_id,
    index_org_contact_histories_on_expires_at: :index_org_contact_behaviors_on_expires_at,
    index_org_contact_histories_on_level_id: :index_org_contact_behaviors_on_level_id,
    index_org_contact_histories_on_occurred_at: :index_org_contact_behaviors_on_occurred_at,
    index_org_contact_histories_on_parent_id: :index_org_contact_behaviors_on_parent_id,
    index_org_document_audits_on_actor_id_and_occurred_at: :index_org_document_behaviors_on_actor_id_and_occurred_at,
    index_org_document_audits_on_event_id: :index_org_document_behaviors_on_event_id,
    index_org_document_audits_on_expires_at: :index_org_document_behaviors_on_expires_at,
    index_org_document_audits_on_level_id: :index_org_document_behaviors_on_level_id,
    index_org_document_audits_on_occurred_at: :index_org_document_behaviors_on_occurred_at,
    index_org_document_audits_on_subject_id: :index_org_document_behaviors_on_subject_id,
    index_org_timeline_audits_on_actor_id_and_occurred_at: :index_org_timeline_behaviors_on_actor_id_and_occurred_at,
    index_org_timeline_audits_on_event_id: :index_org_timeline_behaviors_on_event_id,
    index_org_timeline_audits_on_expires_at: :index_org_timeline_behaviors_on_expires_at,
    index_org_timeline_audits_on_level_id: :index_org_timeline_behaviors_on_level_id,
    index_org_timeline_audits_on_occurred_at: :index_org_timeline_behaviors_on_occurred_at,
    index_org_timeline_audits_on_subject_id: :index_org_timeline_behaviors_on_subject_id,
  }.freeze

  CHECK_CONSTRAINT_RENAMES = {
    app_contact_behaviors: {
      app_contact_histories_event_id_non_negative_check: :app_contact_behaviors_event_id_non_negative_check,
      app_contact_histories_level_id_non_negative_check: :app_contact_behaviors_level_id_non_negative_check,
    },
    app_document_behaviors: {
      app_document_audits_event_id_non_negative_check: :app_document_behaviors_event_id_non_negative_check,
      app_document_audits_level_id_non_negative_check: :app_document_behaviors_level_id_non_negative_check,
    },
    app_timeline_behaviors: {
      app_timeline_audits_event_id_non_negative_check: :app_timeline_behaviors_event_id_non_negative_check,
      app_timeline_audits_level_id_non_negative_check: :app_timeline_behaviors_level_id_non_negative_check,
    },
    com_contact_behaviors: {
      com_contact_audits_event_id_non_negative_check: :com_contact_behaviors_event_id_non_negative_check,
      com_contact_audits_level_id_non_negative_check: :com_contact_behaviors_level_id_non_negative_check,
    },
    com_document_behaviors: {
      com_document_audits_event_id_non_negative_check: :com_document_behaviors_event_id_non_negative_check,
      com_document_audits_level_id_non_negative_check: :com_document_behaviors_level_id_non_negative_check,
    },
    com_timeline_behaviors: {
      com_timeline_audits_event_id_non_negative_check: :com_timeline_behaviors_event_id_non_negative_check,
      com_timeline_audits_level_id_non_negative_check: :com_timeline_behaviors_level_id_non_negative_check,
    },
    org_contact_behaviors: {
      org_contact_histories_event_id_non_negative_check: :org_contact_behaviors_event_id_non_negative_check,
      org_contact_histories_level_id_non_negative_check: :org_contact_behaviors_level_id_non_negative_check,
    },
    org_document_behaviors: {
      org_document_audits_event_id_non_negative_check: :org_document_behaviors_event_id_non_negative_check,
      org_document_audits_level_id_non_negative_check: :org_document_behaviors_level_id_non_negative_check,
    },
    org_timeline_behaviors: {
      org_timeline_audits_event_id_non_negative_check: :org_timeline_behaviors_event_id_non_negative_check,
      org_timeline_audits_level_id_non_negative_check: :org_timeline_behaviors_level_id_non_negative_check,
    },
  }.freeze

  def up
    safety_assured do
      TABLE_RENAMES.each do |from, to|
        rename_table(from, to) if table_exists?(from)
      end

      rename_indexes(INDEX_RENAMES)
      rename_check_constraints(CHECK_CONSTRAINT_RENAMES)
    end
  end

  def down
    safety_assured do
      rename_check_constraints(reverse_nested_hash(CHECK_CONSTRAINT_RENAMES))
      rename_indexes(INDEX_RENAMES.invert)

      TABLE_RENAMES.each do |from, to|
        rename_table(to, from) if table_exists?(to)
      end
    end
  end

  private

  def rename_indexes(mapping)
    mapping.each do |from, to|
      next unless index_named?(from)
      next if index_named?(to)

      table = index_table_name(from)
      next if table.blank?

      rename_index(table, from, to)
    end
  end

  def rename_check_constraints(mapping)
    mapping.each do |table, constraints|
      next unless table_exists?(table)

      constraints.each do |from, to|
        next unless check_constraint_named?(table, from)
        next if check_constraint_named?(table, to)

        execute <<~SQL.squish
          ALTER TABLE #{quote_table_name(table)}
          RENAME CONSTRAINT #{quote_column_name(from)} TO #{quote_column_name(to)}
        SQL
      end
    end
  end

  def check_constraint_named?(table, constraint_name)
    quoted_table = connection.quote(table.to_s)
    quoted_constraint = connection.quote(constraint_name.to_s)

    select_value(<<~SQL.squish).present?
      SELECT 1
      FROM pg_constraint c
      INNER JOIN pg_class t ON t.oid = c.conrelid
      WHERE c.contype = 'c'
        AND t.relname = #{quoted_table}
        AND c.conname = #{quoted_constraint}
      LIMIT 1
    SQL
  end

  def index_table_name(index_name)
    table_name = connection.select_value(<<~SQL.squish)
      SELECT tablename
      FROM pg_indexes
      WHERE schemaname = ANY(current_schemas(false))
        AND indexname = #{connection.quote(index_name.to_s)}
      LIMIT 1
    SQL

    table_name&.to_sym
  end

  def index_named?(index_name)
    connection.select_value(<<~SQL.squish).present?
      SELECT 1
      FROM pg_indexes
      WHERE schemaname = ANY(current_schemas(false))
        AND indexname = #{connection.quote(index_name.to_s)}
      LIMIT 1
    SQL
  end

  def reverse_nested_hash(hash)
    hash.to_h do |key, value|
      [key, value.invert]
    end
  end
end
