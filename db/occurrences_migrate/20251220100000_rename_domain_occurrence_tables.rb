# frozen_string_literal: true

class RenameDomainOccurrenceTables < ActiveRecord::Migration[8.2]
  def up
    if table_exists?(:domain_occurences) && !table_exists?(:domain_occurrences)
      rename_table :domain_occurences, :domain_occurrences
    end

    if table_exists?(:domain_occurence_statuses) && !table_exists?(:domain_occurrence_statuses)
      rename_table :domain_occurence_statuses, :domain_occurrence_statuses
    end

    rename_domain_occurrence_indexes_and_constraints(from: :domain_occurences, to: :domain_occurrences)
  end

  def down
    rename_domain_occurrence_indexes_and_constraints(from: :domain_occurrences, to: :domain_occurences)

    if table_exists?(:domain_occurrence_statuses) && !table_exists?(:domain_occurence_statuses)
      rename_table :domain_occurrence_statuses, :domain_occurence_statuses
    end

    if table_exists?(:domain_occurrences) && !table_exists?(:domain_occurences)
      rename_table :domain_occurrences, :domain_occurences
    end
  end

  private

  def rename_domain_occurrence_indexes_and_constraints(from:, to:)
    return unless table_exists?(to)

    public_id_old = "index_#{from}_on_public_id"
    public_id_new = "index_#{to}_on_public_id"
    body_old = "index_#{from}_on_body"
    body_new = "index_#{to}_on_body"

    rename_index to, public_id_old, public_id_new if index_exists?(to, :public_id, name: public_id_old)
    rename_index to, body_old, body_new if index_exists?(to, :body, name: body_old)

    length_old = "chk_#{from}_public_id_length"
    length_new = "chk_#{to}_public_id_length"
    format_old = "chk_#{from}_public_id_format"
    format_new = "chk_#{to}_public_id_format"

    if check_constraint_exists?(to, name: length_old)
      remove_check_constraint to, name: length_old
      add_check_constraint to, "char_length(public_id) = 21", name: length_new
    end

    if check_constraint_exists?(to, name: format_old)
      remove_check_constraint to, name: format_old
      add_check_constraint to, "public_id ~ '^[A-Za-z0-9_-]{21}$'", name: format_new
    end
  end
end
