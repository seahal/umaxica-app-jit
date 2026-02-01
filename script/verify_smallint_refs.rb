#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../config/environment"

module VerifySmallintRefs
  extend self

  NEWS_STATUS_TABLES = %w(app_timeline_statuses com_timeline_statuses org_timeline_statuses).freeze
  NEWS_CATEGORY_MASTERS = %w(app_timeline_category_masters com_timeline_category_masters
                             org_timeline_category_masters).freeze
  NEWS_TAG_MASTERS = %w(app_timeline_tag_masters com_timeline_tag_masters org_timeline_tag_masters).freeze
  NEWS_CATEGORY_TABLES = %w(app_timeline_categories com_timeline_categories org_timeline_categories).freeze
  NEWS_TAG_TABLES = %w(app_timeline_tags com_timeline_tags org_timeline_tags).freeze
  NEWS_CATEGORY_FOREIGN_KEYS = {
    "app_timeline_categories" => :app_timeline_category_master_id,
    "com_timeline_categories" => :com_timeline_category_master_id,
    "org_timeline_categories" => :org_timeline_category_master_id,
  }.freeze
  NEWS_TAG_FOREIGN_KEYS = {
    "app_timeline_tags" => :app_timeline_tag_master_id,
    "com_timeline_tags" => :com_timeline_tag_master_id,
    "org_timeline_tags" => :org_timeline_tag_master_id,
  }.freeze

  DOCUMENT_REFERENCE_TABLES = %w(
    app_document_statuses
    com_document_statuses
    org_document_statuses
    app_document_category_masters
    com_document_category_masters
    org_document_category_masters
    app_document_tag_masters
    com_document_tag_masters
    org_document_tag_masters
  ).freeze
  TIMESTAMP_COLUMNS = %i(created_at updated_at).freeze

  ERROR_PREFIX = "verify_smallint_refs".freeze

  def run!
    verify_news_tables
    verify_document_tables

    puts "verify_smallint_refs: all checks passed"
  end

  private

  def verify_news_tables
    connection = NewsRecord.connection
    NEWS_STATUS_TABLES.each { |table| assert_smallint_column(connection, table, :id) }
    NEWS_CATEGORY_MASTERS.each do |table|
      assert_smallint_column(connection, table, :id)
      assert_smallint_column(connection, table, :parent_id)
    end
    NEWS_TAG_MASTERS.each do |table|
      assert_smallint_column(connection, table, :id)
      assert_smallint_column(connection, table, :parent_id)
    end
    NEWS_CATEGORY_FOREIGN_KEYS.each { |table, column| assert_smallint_column(connection, table, column) }
    NEWS_TAG_FOREIGN_KEYS.each { |table, column| assert_smallint_column(connection, table, column) }
    %w(app_timelines com_timelines org_timelines).each do |table|
      assert_smallint_column(connection, table, :status_id)
    end
  end

  def verify_document_tables
    connection = DocumentRecord.connection
    DOCUMENT_REFERENCE_TABLES.each do |table|
      TIMESTAMP_COLUMNS.each do |column|
        next unless connection.column_exists?(table, column)

        raise_error("#{table} still has #{column}")
      end
    end
  end

  def assert_smallint_column(connection, table, column_name)
    column = connection.columns(table).find { |col| col.name == column_name.to_s }
    raise_error("#{table}.#{column_name} is missing") unless column

    unless column.sql_type_metadata.sql_type == "smallint"
      raise_error("#{table}.#{column_name} is not smallint (#{column.sql_type_metadata.sql_type})")
    end
  end

  def raise_error(message)
    warn("#{ERROR_PREFIX}: #{message}")
    exit(1)
  end
end

VerifySmallintRefs.run!
