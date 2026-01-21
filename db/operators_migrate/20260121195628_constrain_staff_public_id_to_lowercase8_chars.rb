# frozen_string_literal: true

class ConstrainStaffPublicIdToLowercase8Chars < ActiveRecord::Migration[8.2]
  def up
    # Remove default first
    safety_assured do
      change_column_default :staffs, :public_id, from: "", to: nil
    end

    # Change column to limit: 8, null: false (breaking change; existing data must be cleared/backfilled first)
    safety_assured do
      change_column :staffs, :public_id, :string, limit: 8, null: false
    end

    # Add CHECK constraint for length = 8
    safety_assured do
      execute <<~SQL.squish
        ALTER TABLE staffs
        ADD CONSTRAINT chk_staffs_public_id_length
        CHECK (char_length(public_id) = 8);
      SQL
    end

    # Add CHECK constraint for allowed characters (human-readable set excluding i, o, 0, 1, s, z, g)
    safety_assured do
      execute <<~SQL.squish
        ALTER TABLE staffs
        ADD CONSTRAINT chk_staffs_public_id_format
        CHECK (public_id ~ '^[abcdefhjklmnpqrtuvwxy23456789]{8}$');
      SQL
    end
  end

  def down
    safety_assured do
      execute <<~SQL.squish
        ALTER TABLE staffs
        DROP CONSTRAINT IF EXISTS chk_staffs_public_id_format;
      SQL

      execute <<~SQL.squish
        ALTER TABLE staffs
        DROP CONSTRAINT IF EXISTS chk_staffs_public_id_length;
      SQL

      change_column :staffs, :public_id, :string, limit: 255, null: true
      change_column_default :staffs, :public_id, ""
    end
  end
end
