# frozen_string_literal: true

class ReplaceNoneWithNeyoInGuestContacts < ActiveRecord::Migration[8.2]
  AUDIT_SUFFIXES = %w(contact_audit_events contact_audit_levels).freeze

  def up
    %w(app com org).each do |prefix|
      status_table = "#{prefix}_contact_statuses"
      category_table = "#{prefix}_contact_categories"
      contact_table = "#{prefix}_contacts"

      insert_status(status_table, "NEYO")
      insert_status(category_table, "NEYO")

      update_column_value(contact_table, :status_id, from: "NONE", to: "NEYO")
      update_column_value(contact_table, :category_id, from: "NONE", to: "NEYO")

      change_column_default_if_exists(contact_table, :status_id, from: "NONE", to: "NEYO")
      change_column_default_if_exists(contact_table, :category_id, from: "NONE", to: "NEYO")

      delete_status(status_table, "NONE")
      delete_status(category_table, "NONE")
    end

    %w(app com org).each do |prefix|
      AUDIT_SUFFIXES.each do |suffix|
        table = "#{prefix}_#{suffix}"
        insert_status(table, "NEYO")
        delete_status(table, "NONE")
      end
    end

    %w(app com org).each do |prefix|
      histories = ["#{prefix}_contact_histories"]
      histories << "#{prefix}_contact_audits" if prefix == "com"

      histories.each do |table|
        update_column_value(table, :event_id, from: "NONE", to: "NEYO")
        update_column_value(table, :level_id, from: "NONE", to: "NEYO")
        change_column_default_if_exists(table, :event_id, from: "NONE", to: "NEYO")
        change_column_default_if_exists(table, :level_id, from: "NONE", to: "NEYO")
      end
    end
  end

  def down
    %w(app com org).each do |prefix|
      status_table = "#{prefix}_contact_statuses"
      category_table = "#{prefix}_contact_categories"
      contact_table = "#{prefix}_contacts"

      insert_status(status_table, "NONE")
      insert_status(category_table, "NONE")

      update_column_value(contact_table, :status_id, from: "NEYO", to: "NONE")
      update_column_value(contact_table, :category_id, from: "NEYO", to: "NONE")

      change_column_default_if_exists(contact_table, :status_id, from: "NEYO", to: "NONE")
      change_column_default_if_exists(contact_table, :category_id, from: "NEYO", to: "NONE")

      delete_status(status_table, "NEYO")
      delete_status(category_table, "NEYO")
    end

    %w(app com org).each do |prefix|
      AUDIT_SUFFIXES.each do |suffix|
        table = "#{prefix}_#{suffix}"
        insert_status(table, "NONE")
        delete_status(table, "NEYO")
      end
    end

    %w(app com org).each do |prefix|
      histories = ["#{prefix}_contact_histories"]
      histories << "#{prefix}_contact_audits" if prefix == "com"

      histories.each do |table|
        update_column_value(table, :event_id, from: "NEYO", to: "NONE")
        update_column_value(table, :level_id, from: "NEYO", to: "NONE")
        change_column_default_if_exists(table, :event_id, from: "NEYO", to: "NONE")
        change_column_default_if_exists(table, :level_id, from: "NEYO", to: "NONE")
      end
    end
  end

  private

  def insert_status(table, id)
    return unless table_exists?(table)

    cols = [:id]
    vals = [id]

    if column_exists?(table, :active)
      cols << :active
      vals << true
    end

    if column_exists?(table, :position)
      cols << :position
      vals << 0
    end

    if column_exists?(table, :description)
      cols << :description
      vals << id
    end

    if column_exists?(table, :created_at)
      cols << :created_at
      vals << Time.current
    end

    if column_exists?(table, :updated_at)
      cols << :updated_at
      vals << Time.current
    end

    safety_assured do
      execute <<~SQL.squish
        INSERT INTO #{table} (#{cols.join(", ")})
        VALUES (#{vals.map { |v| connection.quote(v) }.join(", ")})
        ON CONFLICT (id) DO NOTHING
      SQL
    end
  end

  def update_column_value(table, column, from:, to:)
    return unless table_exists?(table) && column_exists?(table, column)

    safety_assured do
      execute <<~SQL.squish
        UPDATE #{table}
        SET #{column} = '#{to}'
        WHERE #{column} = '#{from}'
      SQL
    end
  end

  def change_column_default_if_exists(table, column, from:, to:)
    return unless table_exists?(table) && column_exists?(table, column)

    change_column_default table, column, from: from, to: to
  end

  def delete_status(table, id)
    return unless table_exists?(table)

    safety_assured do
      execute <<~SQL.squish
        DELETE FROM #{table}
        WHERE id = '#{id}'
      SQL
    end
  end
end
