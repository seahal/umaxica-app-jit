class CreateAvatarIdentityCoreTables < ActiveRecord::Migration[8.2]
  def change
    create_table :handles, id: :string do |t|
      t.string :public_id, null: false
      t.string :handle, null: false
      t.boolean :is_system, null: false, default: false
      t.timestamptz :cooldown_until, null: false
      t.references :handle_status, type: :string, foreign_key: true
      t.timestamps
    end

    add_index :handles, :public_id, unique: true
    add_index :handles, :cooldown_until
    add_index :handles, :is_system
    add_index :handles, :handle, unique: true, where: "is_system = false", name: "uniq_handles_handle_non_system"

    create_table :avatars, id: :string do |t|
      t.string :public_id, null: false
      t.string :moniker, null: false
      t.jsonb :image_data, null: false, default: {}
      t.string :owner_organization_id
      t.string :representing_organization_id
      t.string :active_handle_id, null: false
      t.references :capability, type: :string, null: false, foreign_key: { to_table: :avatar_capabilities }
      t.string :avatar_status_id
      t.timestamps
    end

    add_index :avatars, :public_id, unique: true
    add_index :avatars, :owner_organization_id
    add_index :avatars, :representing_organization_id
    add_index :avatars, :active_handle_id
    add_foreign_key :avatars, :handles, column: :active_handle_id

    create_table :handle_assignments, id: :string do |t|
      t.string :avatar_id, null: false
      t.string :handle_id, null: false
      t.timestamptz :valid_from, null: false
      t.timestamptz :valid_to, null: false, default: -> { "'infinity'::timestamptz" }
      t.references :handle_assignment_status, type: :string, foreign_key: true
      t.string :assigned_by_actor_id
      t.timestamps
    end

    add_index :handle_assignments, :handle_id, unique: true, where: "valid_to = 'infinity'"
    add_index :handle_assignments, :avatar_id, unique: true, where: "valid_to = 'infinity'"
    add_index :handle_assignments, [ :avatar_id, :valid_from ], order: { valid_from: :desc }
    add_index :handle_assignments, [ :handle_id, :valid_from ], order: { valid_from: :desc }
    add_foreign_key :handle_assignments, :avatars
    add_foreign_key :handle_assignments, :handles

    create_table :avatar_monikers, id: :string do |t|
      t.string :avatar_id, null: false
      t.string :moniker, null: false
      t.timestamptz :valid_from, null: false
      t.timestamptz :valid_to, null: false, default: -> { "'infinity'::timestamptz" }
      t.references :avatar_moniker_status, type: :string, foreign_key: true
      t.string :set_by_actor_id
      t.timestamps
    end

    add_index :avatar_monikers, :avatar_id, unique: true, where: "valid_to = 'infinity'"
    add_index :avatar_monikers, [ :avatar_id, :valid_from ], order: { valid_from: :desc }
    add_foreign_key :avatar_monikers, :avatars

    create_table :avatar_memberships, id: :string do |t|
      t.string :avatar_id, null: false
      t.string :actor_id, null: false
      t.string :role_id, null: false
      t.timestamptz :valid_from, null: false
      t.timestamptz :valid_to, null: false, default: -> { "'infinity'::timestamptz" }
      t.references :avatar_membership_status, type: :string, foreign_key: true
      t.string :granted_by_actor_id
      t.timestamps
    end

    add_index :avatar_memberships, [ :avatar_id, :actor_id ], unique: true, where: "valid_to = 'infinity'"
    add_index :avatar_memberships, :actor_id, where: "valid_to = 'infinity'"
    add_index :avatar_memberships, :avatar_id, where: "valid_to = 'infinity'"
    add_foreign_key :avatar_memberships, :avatars

    create_table :avatar_ownership_periods, id: :string do |t|
      t.string :avatar_id, null: false
      t.string :owner_organization_id, null: false
      t.timestamptz :valid_from, null: false
      t.timestamptz :valid_to, null: false, default: -> { "'infinity'::timestamptz" }
      t.references :avatar_ownership_status, type: :string, foreign_key: true
      t.string :transferred_by_actor_id
      t.timestamps
    end

    add_index :avatar_ownership_periods, :avatar_id, unique: true, where: "valid_to = 'infinity'"
    add_index :avatar_ownership_periods, :owner_organization_id, where: "valid_to = 'infinity'"
    add_foreign_key :avatar_ownership_periods, :avatars

    create_table :posts, id: :string do |t|
      t.string :public_id, null: false
      t.string :author_avatar_id, null: false
      t.references :post_status, type: :string, null: false, foreign_key: true
      t.text :body, null: false
      t.string :created_by_actor_id, null: false
      t.string :published_by_actor_id
      t.timestamptz :published_at
      t.timestamps
    end

    add_index :posts, :public_id, unique: true
    add_index :posts, [ :author_avatar_id, :created_at ], order: { created_at: :desc }
    add_foreign_key :posts, :avatars, column: :author_avatar_id

    create_table :post_reviews, id: :string do |t|
      t.string :post_id, null: false
      t.string :reviewer_actor_id, null: false
      t.references :post_review_status, type: :string, null: false, foreign_key: true
      t.text :comment
      t.timestamptz :decided_at
      t.timestamps
    end

    add_index :post_reviews, [ :post_id, :reviewer_actor_id ], unique: true
    add_index :post_reviews, :reviewer_actor_id, where: "decided_at IS NULL"
    add_foreign_key :post_reviews, :posts
  end
end
