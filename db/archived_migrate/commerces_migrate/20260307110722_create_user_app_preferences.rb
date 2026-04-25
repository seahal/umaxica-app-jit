# frozen_string_literal: true

class CreateUserAppPreferences < ActiveRecord::Migration[8.2]
  def change
    create_table(:user_app_preferences, id: :bigserial) do |t|
      t.bigint(:user_id, null: false)
      t.references(
        :app_preference,
        null: false,
        foreign_key: { on_delete: :cascade },
        type: :bigserial,
      )

      t.timestamps
    end

    add_index(:user_app_preferences, :user_id)
    add_index(:user_app_preferences, %i(user_id app_preference_id), unique: true)
  end
end
