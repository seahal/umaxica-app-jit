# frozen_string_literal: true

class ReplaceNoneWithNeyoInGuestContacts < ActiveRecord::Migration[8.2]
  def up
    %w(app com org).each do |prefix|
      contact_table = "#{prefix}_contacts"

      update_column_value(contact_table, :status_id, from: "NONE", to: "NEYO")
      update_column_value(contact_table, :category_id, from: "NONE", to: "NEYO")

      change_column_default_if_exists(contact_table, :status_id, from: "NONE", to: "NEYO")
      change_column_default_if_exists(contact_table, :category_id, from: "NONE", to: "NEYO")
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
      contact_table = "#{prefix}_contacts"

      update_column_value(contact_table, :status_id, from: "NEYO", to: "NONE")
      update_column_value(contact_table, :category_id, from: "NEYO", to: "NONE")

      change_column_default_if_exists(contact_table, :status_id, from: "NEYO", to: "NONE")
      change_column_default_if_exists(contact_table, :category_id, from: "NEYO", to: "NONE")
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
end
