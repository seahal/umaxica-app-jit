# frozen_string_literal: true

class AddPositionToPreferenceReferenceTables < ActiveRecord::Migration[8.2]
  REFERENCE_TABLES = %i(
    app_preference_statuses
    com_preference_statuses
    org_preference_statuses
    app_preference_audit_levels
    com_preference_audit_levels
    org_preference_audit_levels
    app_preference_audit_events
    com_preference_audit_events
    org_preference_audit_events
    app_preference_language_options
    app_preference_region_options
    app_preference_timezone_options
    app_preference_colortheme_options
    com_preference_language_options
    com_preference_region_options
    com_preference_timezone_options
    com_preference_colortheme_options
    org_preference_language_options
    org_preference_region_options
    org_preference_timezone_options
    org_preference_colortheme_options
  ).freeze

  disable_ddl_transaction!

  def change
    REFERENCE_TABLES.each do |table|
      next unless table_exists?(table)

      unless column_exists?(table, :position)
        add_column(table, :position, :integer)
      end

      quoted_table = "\"#{table}\""

      safety_assured do
        reversible do |dir|
          dir.up do
            execute(<<~SQL.squish)
              WITH numbered AS (
                SELECT id, row_number() OVER (ORDER BY id) as rn
                FROM #{quoted_table}
              )
              UPDATE #{quoted_table}
              SET position = numbered.rn
              FROM numbered
              WHERE #{quoted_table}.id = numbered.id
            SQL
          end
        end

        change_column_null(table, :position, false)

        # Check constraints and indexes carefully
        # Note: index_exists? and checking constraints prevents duplication errors

        unless index_exists?(table, :position, unique: true, name: "#{table}_position_unique")
          add_index(table, :position, unique: true, name: "#{table}_position_unique")
        end

        # Handling constraint checks with rescue as check_constraint_exists? might vary in availability/reliability
        begin
          add_check_constraint(table, "position > 0", name: "#{table}_position_positive")
        rescue ActiveRecord::StatementInvalid => e
          raise e unless e.message.include?("already exists")
        end
      end
    end
  end
end
