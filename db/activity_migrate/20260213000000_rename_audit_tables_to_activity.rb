# frozen_string_literal: true

class RenameAuditTablesToActivity < ActiveRecord::Migration[8.2]
  TABLE_RENAMES = {
    app_preference_audit_events: :app_preference_activity_events,
    app_preference_audit_levels: :app_preference_activity_levels,
    app_preference_audits: :app_preference_activities,
    com_preference_audit_events: :com_preference_activity_events,
    com_preference_audit_levels: :com_preference_activity_levels,
    com_preference_audits: :com_preference_activities,
    org_preference_audit_events: :org_preference_activity_events,
    org_preference_audit_levels: :org_preference_activity_levels,
    org_preference_audits: :org_preference_activities,
    staff_audit_events: :staff_activity_events,
    staff_audit_levels: :staff_activity_levels,
    staff_audits: :staff_activities,
    user_audit_events: :user_activity_events,
    user_audit_levels: :user_activity_levels,
    user_audits: :user_activities,
  }.freeze

  INDEX_RENAMES = {
    index_app_preference_audits_on_actor_id_and_occurred_at: :index_app_preference_activities_on_actor_id_and_occurred_at,
    index_app_preference_audits_on_event_id: :index_app_preference_activities_on_event_id,
    index_app_preference_audits_on_expires_at: :index_app_preference_activities_on_expires_at,
    index_app_preference_audits_on_level_id: :index_app_preference_activities_on_level_id,
    index_app_preference_audits_on_occurred_at: :index_app_preference_activities_on_occurred_at,
    index_app_preference_audits_on_subject_id: :index_app_preference_activities_on_subject_id,
    index_com_preference_audits_on_actor_id_and_occurred_at: :index_com_preference_activities_on_actor_id_and_occurred_at,
    index_com_preference_audits_on_event_id: :index_com_preference_activities_on_event_id,
    index_com_preference_audits_on_expires_at: :index_com_preference_activities_on_expires_at,
    index_com_preference_audits_on_level_id: :index_com_preference_activities_on_level_id,
    index_com_preference_audits_on_occurred_at: :index_com_preference_activities_on_occurred_at,
    index_com_preference_audits_on_subject_id: :index_com_preference_activities_on_subject_id,
    index_org_preference_audits_on_actor_id_and_occurred_at: :index_org_preference_activities_on_actor_id_and_occurred_at,
    index_org_preference_audits_on_event_id: :index_org_preference_activities_on_event_id,
    index_org_preference_audits_on_expires_at: :index_org_preference_activities_on_expires_at,
    index_org_preference_audits_on_level_id: :index_org_preference_activities_on_level_id,
    index_org_preference_audits_on_occurred_at: :index_org_preference_activities_on_occurred_at,
    index_org_preference_audits_on_subject_id: :index_org_preference_activities_on_subject_id,
    index_staff_audits_on_event_id: :index_staff_activities_on_event_id,
    index_staff_audits_on_level_id: :index_staff_activities_on_level_id,
    index_staff_identity_audits_on_actor: :index_staff_activities_on_actor,
    index_staff_identity_audits_on_actor_id_and_occurred_at: :index_staff_activities_on_actor_id_and_occurred_at,
    index_staff_identity_audits_on_expires_at: :index_staff_activities_on_expires_at,
    index_staff_identity_audits_on_occurred_at: :index_staff_activities_on_occurred_at,
    index_staff_identity_audits_on_subject_id: :index_staff_activities_on_subject_id,
    index_user_audits_on_event_id: :index_user_activities_on_event_id,
    index_user_audits_on_level_id: :index_user_activities_on_level_id,
    index_user_identity_audits_on_actor: :index_user_activities_on_actor,
    index_user_identity_audits_on_actor_id_and_occurred_at: :index_user_activities_on_actor_id_and_occurred_at,
    index_user_identity_audits_on_expires_at: :index_user_activities_on_expires_at,
    index_user_identity_audits_on_occurred_at: :index_user_activities_on_occurred_at,
    index_user_identity_audits_on_subject_id: :index_user_activities_on_subject_id,
  }.freeze

  CHECK_CONSTRAINT_RENAMES = {
    app_preference_activities: {
      app_preference_audits_event_id_non_negative_check: :app_preference_activities_event_id_non_negative_check,
      app_preference_audits_level_id_non_negative_check: :app_preference_activities_level_id_non_negative_check,
    },
    com_preference_activities: {
      com_preference_audits_event_id_non_negative_check: :com_preference_activities_event_id_non_negative_check,
      com_preference_audits_level_id_non_negative_check: :com_preference_activities_level_id_non_negative_check,
    },
    org_preference_activities: {
      org_preference_audits_event_id_non_negative_check: :org_preference_activities_event_id_non_negative_check,
      org_preference_audits_level_id_non_negative_check: :org_preference_activities_level_id_non_negative_check,
    },
    staff_activities: {
      staff_audits_event_id_non_negative_check: :staff_activities_event_id_non_negative_check,
      staff_audits_level_id_non_negative_check: :staff_activities_level_id_non_negative_check,
    },
    user_activities: {
      user_audits_event_id_non_negative_check: :user_activities_event_id_non_negative_check,
      user_audits_level_id_non_negative_check: :user_activities_level_id_non_negative_check,
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
