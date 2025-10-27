class ChangeAllDatetimeToTimestamptzInToken < ActiveRecord::Migration[8.1]
  def up
    # staff_tokens
    change_table :staff_tokens, bulk: true do |t|
      t.change :created_at, :timestamptz, null: false
      t.change :updated_at, :timestamptz, null: false
    end

    # user_tokens
    change_table :user_tokens, bulk: true do |t|
      t.change :created_at, :timestamptz, null: false
      t.change :updated_at, :timestamptz, null: false
    end
  end

  def down
    # staff_tokens
    change_table :staff_tokens, bulk: true do |t|
      t.change :created_at, :datetime, null: false
      t.change :updated_at, :datetime, null: false
    end

    # user_tokens
    change_table :user_tokens, bulk: true do |t|
      t.change :created_at, :datetime, null: false
      t.change :updated_at, :datetime, null: false
    end
  end
end
