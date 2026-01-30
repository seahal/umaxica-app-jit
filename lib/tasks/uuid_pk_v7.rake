# frozen_string_literal: true

# PostgreSQL 18+ uuidv7() audit task
# This task inspects all UUID primary key tables and reports their DEFAULT values.
# Usage: rake uuid:pk:report

namespace :uuid do
  namespace :pk do
    desc "Report UUID primary key DEFAULT values across all tables"
    task report: :environment do
      sql = <<~SQL.squish
        SELECT
          t.tablename,
          a.attname AS column_name,
          COALESCE(pg_get_expr(d.adbin, d.adrelid), '(no default)') AS default_value
        FROM pg_catalog.pg_tables t
        JOIN pg_catalog.pg_class c ON c.relname = t.tablename AND c.relnamespace = (
          SELECT oid FROM pg_catalog.pg_namespace WHERE nspname = t.schemaname
        )
        JOIN pg_catalog.pg_attribute a ON a.attrelid = c.oid
        LEFT JOIN pg_catalog.pg_attrdef d ON d.adrelid = c.oid AND d.adnum = a.attnum
        JOIN pg_catalog.pg_type ty ON ty.oid = a.atttypid
        WHERE t.schemaname = 'public'
          AND a.attname = 'id'
          AND ty.typname = 'uuid'
          AND NOT a.attisdropped
        ORDER BY t.tablename;
      SQL

      results = ActiveRecord::Base.connection.execute(sql)

      if results.count.zero?
        puts "✓ No UUID primary key tables found."
        exit 0
      end

      puts "=" * 80
      puts "UUID Primary Key Tables (PostgreSQL 18+ uuidv7() requirement)"
      puts "=" * 80
      puts

      v7_tables = []
      v4_tables = []
      no_default_tables = []

      results.each do |row|
        table_name = row["tablename"]
        default_value = row["default_value"]

        case default_value
        when /uuidv7\(\)/i
          v7_tables << table_name
        when "(no default)"
          no_default_tables << table_name
        else
          v4_tables << { name: table_name, default: default_value }
        end
      end

      # Report UUIDv7 (OK)
      if v7_tables.any?
        puts "✓ Tables with UUIDv7 DEFAULT (#{v7_tables.count}):"
        v7_tables.each { |t| puts "  - #{t}" }
        puts
      end

      # Report UUIDv4 or other (NEEDS MIGRATION)
      if v4_tables.any?
        puts "⚠ Tables with UUIDv4 or non-v7 DEFAULT (#{v4_tables.count}):"
        v4_tables.each { |t| puts "  - #{t[:name]}: #{t[:default]}" }
        puts
      end

      # Report no default (NEEDS MIGRATION)
      if no_default_tables.any?
        puts "⚠ Tables with NO DEFAULT (#{no_default_tables.count}):"
        no_default_tables.each { |t| puts "  - #{t}" }
        puts
      end

      # Summary
      puts "=" * 80
      puts "Summary:"
      puts "  Total UUID PK tables: #{results.count}"
      puts "  ✓ UUIDv7:             #{v7_tables.count}"
      puts "  ⚠ Needs migration:    #{v4_tables.count + no_default_tables.count}"
      puts "=" * 80

      if v4_tables.any? || no_default_tables.any?
        puts
        puts I18n.t("uuid_pk.report.action_required")
        exit 1
      else
        puts
        puts "✓ All UUID primary key tables are using UUIDv7."
        exit 0
      end
    end
  end
end
