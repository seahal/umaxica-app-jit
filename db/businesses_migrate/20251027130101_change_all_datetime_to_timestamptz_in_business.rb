class ChangeAllDatetimeToTimestamptzInBusiness < ActiveRecord::Migration[8.1]
  def up
    # documents
    change_table :documents, bulk: true do |t|
      t.change :created_at, :timestamptz, null: false
      t.change :updated_at, :timestamptz, null: false
    end

    # entity_statuses
    change_table :entity_statuses, bulk: true do |t|
      t.change :created_at, :timestamptz, null: false
      t.change :updated_at, :timestamptz, null: false
    end

    # timelines
    change_table :timelines, bulk: true do |t|
      t.change :created_at, :timestamptz, null: false
      t.change :updated_at, :timestamptz, null: false
    end
  end

  def down
    # documents
    change_table :documents, bulk: true do |t|
      t.change :created_at, :datetime, null: false
      t.change :updated_at, :datetime, null: false
    end

    # entity_statuses
    change_table :entity_statuses, bulk: true do |t|
      t.change :created_at, :datetime, null: false
      t.change :updated_at, :datetime, null: false
    end

    # timelines
    change_table :timelines, bulk: true do |t|
      t.change :created_at, :datetime, null: false
      t.change :updated_at, :datetime, null: false
    end
  end
end
