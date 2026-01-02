# frozen_string_literal: true

class SeedRemainingFixtures < ActiveRecord::Migration[8.2]
  def up
    # Seed StaffIdentityStatus
    execute "INSERT INTO staff_identity_statuses (id) VALUES ('NEYO') ON CONFLICT (id) DO NOTHING"

    # Seed UserIdentityStatus
    execute "INSERT INTO user_identity_statuses (id) VALUES ('NEYO') ON CONFLICT (id) DO NOTHING"

    # Seed Users
    # 1. one
    execute <<~SQL.squish
      INSERT INTO users (id, public_id, status_id, created_at, updated_at)
      VALUES (
        '11111111-1111-1111-1111-111111111111',
        'one_user_public_id01',
        'NEYO',
        NOW(),
        NOW()
      ) ON CONFLICT (id) DO NOTHING
    SQL

    # 2. two
    execute <<~SQL.squish
      INSERT INTO users (id, public_id, status_id, created_at, updated_at)
      VALUES (
        '22222222-2222-2222-2222-222222222222',
        'two_user_public_id02',
        'NEYO',
        NOW(),
        NOW()
      ) ON CONFLICT (id) DO NOTHING
    SQL

    # 3. neyo
    execute <<~SQL.squish
      INSERT INTO users (id, public_id, status_id, created_at, updated_at)
      VALUES (
        '00000000-0000-0000-0000-000000000000',
        NULL,
        'NEYO',
        NOW(),
        NOW()
      ) ON CONFLICT (id) DO NOTHING
    SQL
  end

  def down
    execute <<~SQL.squish
      DELETE FROM users
      WHERE id IN (
        '11111111-1111-1111-1111-111111111111',
        '22222222-2222-2222-2222-222222222222',
        '00000000-0000-0000-0000-000000000000'
      )
    SQL
    execute "DELETE FROM user_identity_statuses WHERE id = 'NEYO'"
    execute "DELETE FROM staff_identity_statuses WHERE id = 'NEYO'"
  end
end
