# frozen_string_literal: true

class RenameAdminMessageToOperatorMessage < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      rename_table(:admin_messages, :operator_messages)
      rename_public_id_index
      rename_staff_message_id_index
    end
  end

  private

  def rename_public_id_index
    old_name = :index_admin_messages_on_public_id
    new_name = :index_operator_messages_on_public_id

    return unless index_exists?(:operator_messages, :public_id, name: old_name)

    rename_index(:operator_messages, old_name, new_name)
  end

  def rename_staff_message_id_index
    old_name = :index_admin_messages_on_staff_message_id
    new_name = :index_operator_messages_on_staff_message_id

    return unless index_exists?(:operator_messages, :staff_message_id, name: old_name)

    rename_index(:operator_messages, old_name, new_name)
  end
end
