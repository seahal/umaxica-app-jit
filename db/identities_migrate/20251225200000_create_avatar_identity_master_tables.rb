class CreateAvatarIdentityMasterTables < ActiveRecord::Migration[8.2]
  def change
    create_table :avatar_capabilities, id: :string do |t|
      t.string :key, null: false
      t.string :name, null: false
      t.text :description
      t.timestamps
    end

    add_index :avatar_capabilities, :key, unique: true

    create_table :handle_statuses, id: :string do |t|
      t.string :key, null: false
      t.string :name, null: false
      t.text :description
      t.timestamps
    end

    add_index :handle_statuses, :key, unique: true

    create_table :handle_assignment_statuses, id: :string do |t|
      t.string :key, null: false
      t.string :name, null: false
      t.text :description
      t.timestamps
    end

    add_index :handle_assignment_statuses, :key, unique: true

    create_table :avatar_moniker_statuses, id: :string do |t|
      t.string :key, null: false
      t.string :name, null: false
      t.text :description
      t.timestamps
    end

    add_index :avatar_moniker_statuses, :key, unique: true

    create_table :avatar_membership_statuses, id: :string do |t|
      t.string :key, null: false
      t.string :name, null: false
      t.text :description
      t.timestamps
    end

    add_index :avatar_membership_statuses, :key, unique: true

    create_table :avatar_ownership_statuses, id: :string do |t|
      t.string :key, null: false
      t.string :name, null: false
      t.text :description
      t.timestamps
    end

    add_index :avatar_ownership_statuses, :key, unique: true

    create_table :post_statuses, id: :string do |t|
      t.string :key, null: false
      t.string :name, null: false
      t.text :description
      t.timestamps
    end

    add_index :post_statuses, :key, unique: true

    create_table :post_review_statuses, id: :string do |t|
      t.string :key, null: false
      t.string :name, null: false
      t.text :description
      t.timestamps
    end

    add_index :post_review_statuses, :key, unique: true

    create_table :avatar_roles, id: :string do |t|
      t.string :key, null: false
      t.string :name, null: false
      t.text :description
      t.timestamps
    end

    add_index :avatar_roles, :key, unique: true

    create_table :avatar_permissions, id: :string do |t|
      t.string :key, null: false
      t.string :name, null: false
      t.text :description
      t.timestamps
    end

    add_index :avatar_permissions, :key, unique: true

    create_table :avatar_role_permissions, id: :string do |t|
      t.string :avatar_role_id, null: false
      t.string :avatar_permission_id, null: false
      t.timestamps
    end

    add_index :avatar_role_permissions,
              [:avatar_role_id, :avatar_permission_id],
              unique: true,
              name: "uniq_avatar_role_permissions"

    add_foreign_key :avatar_role_permissions, :avatar_roles
    add_foreign_key :avatar_role_permissions, :avatar_permissions
  end
end
