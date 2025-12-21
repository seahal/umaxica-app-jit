class CreateUserRecoveryCodes < ActiveRecord::Migration[8.0]
  def change
    create_table :user_recovery_codes, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.string :recovery_code_digest
      t.date :expires_in
      t.timestamps
    end
  end
end
