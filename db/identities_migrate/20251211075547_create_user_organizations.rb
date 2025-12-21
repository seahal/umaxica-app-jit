class CreateUserOrganizations < ActiveRecord::Migration[8.2]
  def change
    create_table :user_organizations, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :organization, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
