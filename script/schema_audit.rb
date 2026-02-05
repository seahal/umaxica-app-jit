#!/usr/bin/env ruby
# frozen_string_literal: true

require 'set'
require 'json'

# --- Mock ActiveRecord for Schema Parsing ---
module ActiveRecord
  class Schema
    def self.[](_version)
      self
    end

    def self.define(_info = {}, &)
      new.instance_eval(&)
    end

    def enable_extension(name)
      SchemaAudit.register_extension(name)
    end

    def create_table(name, options = {}, &block)
      table = TableDefinition.new(name, options)
      yield(table) if block
      SchemaAudit.register_table(table)
    end

    def add_foreign_key(from_table, to_table, options = {})
      SchemaAudit.register_fk(from_table, to_table, options)
    end
  end

  class TableDefinition
    attr_reader :name, :options, :columns, :indexes

    def initialize(name, options)
      @name = name
      @options = options
      @columns = []
      @indexes = []

      # Default ID unless id: false
      unless options[:id] == false
        create_pk(options)
      end
    end

    def create_pk(options)
      pk_name = options[:primary_key] || 'id'
      # In modern Rails schema.rb, id type is not always explicit in create_table options
      # but inferred from config. However, schema.rb often doesn't show it unless it's non-standard.
      # We will assume standard 'primary_key' method is not called if not visible,
      # but we need to capture if 'id' column is explicitly defined as string/uuid later.
      # For now, we add a placeholder PK.
      @columns << { name: pk_name.to_s, type: :implicit_pk, options: {} }
    end

    def method_missing(name, *args)
      # Capture column definitions like t.string "name", ...
      if %i(string text integer bigint boolean datetime timestamptz uuid jsonb inet binary float
            decimal date time timestamp).include?(name)
        col_name = args[0]
        options = args[1] || {}
        @columns << { name: col_name.to_s, type: name, options: options }
      elsif name == :index
        @indexes << { columns: args[0], options: args[1] || {} }
      elsif name == :check_constraint
        # ignore
      end
    end

    # Check constraints etc. ignored for now
    def check_constraint(*args)
    end
  end
end

class SchemaAudit
  class << self
    def reset!
      storage[:tables] = {}
      storage[:extensions] = Set.new
      storage[:foreign_keys] = []
    end

    def register_table(table)
      tables[table.name] = table
    end

    def register_extension(name)
      extensions.add(name)
    end

    def register_fk(from_table, to_table, options)
      foreign_keys << { from_table: from_table, to_table: to_table, options: options }
    end

    def tables
      storage[:tables] ||= {}
    end

    def extensions
      storage[:extensions] ||= Set.new
    end

    def foreign_keys
      storage[:foreign_keys] ||= []
    end

    def storage
      Thread.current[:schema_audit_storage] ||= {}
    end
  end
end

# --- Audit Logic ---

class Auditor
  def initialize(schema_files)
    @schema_files = schema_files
    @pk_issues = []
    @fk_issues = []
    @uuid_remnants = []
    @checks_to_consider = []
  end

  def run
    SchemaAudit.reset!
    @schema_files.each do |file|
      puts "Parsing #{file}..."
      begin
        load file
      rescue StandardError => e
        puts "Error parsing #{file}: #{e.message}"
      end
    end

    analyze_pks
    analyze_fks
    analyze_uuid_remnants_in_schema
    # scan_files_for_uuid # This logic will be separate or part of reporting
  end

  def analyze_pks
    SchemaAudit.tables.each do |name, table|
      # Check if id: false
      if table.options[:id] == false
        @checks_to_consider << { table: name,
                                 issue: "id: false (join table?)",
                                 comment: "Verify if this serves as a join table without PK", }
        next
      end

      # Find PK column
      pk_col = table.columns.find { |c| c[:name] == (table.options[:primary_key] || 'id').to_s }

      unless pk_col
        # Should normally not happen if we add implicit_pk, but if user did something weird
        @pk_issues << { table: name, current: "Missing PK", expected: "bigint", comment: "No primary key found" }
        next
      end

      # In schema.rb, implicit PKs (no t.column 'id') are usually bigint in recent Rails
      # (Record 5.1+ used bigint by default).
      # However, we can't be 100% sure from schema.rb alone if it uses create_table "foo", force: :cascade
      # without explicit config. BUT, usually if it is UUID, it says id: :uuid.
      # If explicit column definition exists for PK, check its type.

      # We need to see if there is an explicit OVERRIDE of the PK column in the columns list.
      explicit_pk = table.columns.find { |c| c[:name] == pk_col[:name] && c[:type] != :implicit_pk }

      final_type = explicit_pk ? explicit_pk[:type] : :bigint # Assume bigint default for Rails 6+

      # table options id: :uuid
      if table.options[:id] == :uuid
        final_type = :uuid
      elsif table.options[:id] == :string
        final_type = :string
      end

      unless [:bigint, :integer].include?(final_type)
        @pk_issues << { table: name,
                        current: final_type,
                        expected: "bigint",
                        comment: "Primary key is not bigint/integer", }
      end

      # Specific check for custom PK name that might imply non-standard usage
      if pk_col[:name] == 'public_id'
        @checks_to_consider << { table: name,
                                 issue: "public_id as PK",
                                 comment: "Verify if public_id is intended to be the primary key (often UUID/String)", }
      end
    end
  end

  def analyze_fks
    # 1. Check explicit FKs in add_foreign_key
    SchemaAudit.foreign_keys.each do |fk|
      from_table = SchemaAudit.tables[fk[:from_table]]
      to_table_name = fk[:to_table]

      unless from_table
        # Might happen if partial schema load
        next
      end

      col_name = fk[:options][:column] || "#{to_table_name.singularize}_id"
      col = from_table.columns.find { |c| c[:name] == col_name.to_s }

      unless col
        # Column not found?
        next
      end

      # Find target table PK
      to_table = SchemaAudit.tables[to_table_name]
      target_pk_type = :unknown
      if to_table
        target_pk_col = to_table.columns.find { |c| c[:name] == (to_table.options[:primary_key] || 'id').to_s }
        # Simplified logic similar to PK check
        target_pk_def =
          to_table.columns.find { |c|
            c[:name] == target_pk_col[:name] && c[:type] != :implicit_pk
          } if target_pk_col
        target_pk_type = (to_table.options[:id] == :uuid) ? :uuid : (target_pk_def ? target_pk_def[:type] : :bigint)
      end

      if col[:type] != :bigint && col[:type] != :integer
        # If target is unknown, we can't strictly mismatch, but we can assume ID should be bigint.
        # However, user asked "Referencing column matches Reference PK".

        expected = (target_pk_type == :unknown) ? "bigint (assumed)" : target_pk_type

        if col[:type] != expected && expected != :unknown
          @fk_issues << { table: fk[:from_table],
                          column: col_name,
                          current: col[:type],
                          target: to_table_name,
                          target_pk: target_pk_type,
                          comment: "Type mismatch", }
        end

        # Also flag if it is UUID regardless, as user wants to remove UUIDs
        # (unless target is UUID, which is also an issue likely logged in PK issues).
        if col[:type] == :uuid
          @fk_issues << { table: fk[:from_table],
                          column: col_name,
                          current: :uuid,
                          target: to_table_name,
                          target_pk: target_pk_type,
                          comment: "UUID FK found", }
        end
      end
    end

    # 2. Check inferred FKs (columns ending in _id)
    SchemaAudit.tables.each do |t_name, table|
      table.columns.each do |col|
        next unless col[:name].end_with?("_id")
        next if col[:name] == (table.options[:primary_key] || 'id').to_s # Skip PK

        # Check if analyzed via explicit FK already? (Skip to avoid dupes if perfectly matched)
        # But simple check: is it bigint?

        if col[:type] != :bigint && col[:type] != :integer
          # Is it polymorphic?
          type_col = table.columns.find { |c| c[:name] == col[:name].sub(/_id$/, '_type') }
          if type_col
            @checks_to_consider << { table: t_name,
                                     issue: "Polymorphic FK #{col[:name]} is #{col[:type]}",
                                     comment: "Should be bigint if references are bigint", }
          else
            # Likely a normal FK
            # Try to guess target
            target_guess = col[:name].sub(/_id$/, '').pluralize
            @fk_issues << { table: t_name,
                            column: col[:name],
                            current: col[:type],
                            target: target_guess,
                            target_pk: "?",
                            comment: "Non-bigint Foreign Key column", }
          end
        end

        # Check index existence
        has_index =
          table.indexes.any? do |idx|
            cols = Array(idx[:columns]).map(&:to_s)
            cols[0] == col[:name] # Primary column in index
          end

        unless has_index
          @checks_to_consider << { table: t_name,
                                   issue: "Missing Index on #{col[:name]}",
                                   comment: "Performance risk for FK", }
        end
      end
    end
  end

  def analyze_uuid_remnants_in_schema
    SchemaAudit.extensions.each do |ext|
      if ext.to_s == 'pgcrypto'
        @uuid_remnants << { type: "Extension",
                            location: "schema",
                            content: "enable_extension 'pgcrypto'",
                            comment: "Check if used for UUIDs or encryption", }
        @checks_to_consider << { issue: "pgcrypto enabled", comment: "Verify necessity" }
      end
      if ext.to_s.include?('uuid')
        @uuid_remnants << { type: "Extension",
                            location: "schema",
                            content: "enable_extension '#{ext}'",
                            comment: "Explicit UUID extension", }
      end
    end

    SchemaAudit.tables.each do |name, table|
      table.columns.each do |col|
        if col[:type] == :uuid
          @uuid_remnants << { type: "Column",
                              location: "Table #{name}",
                              content: "#{col[:name]} (uuid)",
                              comment: "Column is UUID type", }
        end
        if col[:options] && (
          col[:options][:default].to_s.include?("gen_random_uuid") ||
          col[:options][:default].to_s.include?("uuid_generate")
        )
          @uuid_remnants << { type: "Default",
                              location: "Table #{name}.#{col[:name]}",
                              content: col[:options][:default],
                              comment: "Uses UUID generation function", }
        end
      end
    end
  end

  def generate_report
    puts "## Summary"
    puts "- PK issues: #{@pk_issues.size}"
    puts "- FK type mismatches: #{@fk_issues.size}"
    puts "- UUID remnants: #{@uuid_remnants.size}"
    puts "- Checks to consider: #{@checks_to_consider.size}"
    puts ""

    puts "## PK issues"
    puts "| Table | Current PK Definition | Expected | Comment |"
    puts "|---|---|---|---|"
    @pk_issues.each do |i|
      puts "| #{i[:table]} | #{i[:current]} | #{i[:expected]} | #{i[:comment]} |"
    end
    puts ""

    puts "## FK type mismatches"
    puts "| Table | Column | Current Type | Target Table | Target PK | Comment |"
    puts "|---|---|---|---|---|---|"
    @fk_issues.each do |i|
      puts "| #{i[:table]} | #{i[:column]} | #{i[:current]} | #{i[:target]} | #{i[:target_pk]} | #{i[:comment]} |"
    end
    puts ""

    puts "## UUID remnants"
    puts "| Location | Content | Comment |"
    puts "|---|---|---|"
    @uuid_remnants.each do |i|
      puts "| #{i[:location]} | #{i[:content]} | #{i[:comment]} |"
    end
    puts ""

    puts "## Checks to consider"
    puts "| Issue | Comment |"
    puts "|---|---|"
    @checks_to_consider.each do |i|
      desc = i[:table] ? "#{i[:table]}: #{i[:issue]}" : i[:issue]
      puts "| #{desc} | #{i[:comment]} |"
    end
  end
end

String.class_eval do
  def singularize
    # Very basic singularize for script
    return self[0..-2] if self.end_with?('s')

    self
  end

  def pluralize
    self + 's'
  end
end

# Run
files = Dir['db/schema.rb'] + Dir['db/*_schema.rb']
files.uniq!
auditor = Auditor.new(files)
auditor.run
auditor.generate_report
