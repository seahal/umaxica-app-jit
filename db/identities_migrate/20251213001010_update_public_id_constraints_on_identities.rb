class UpdatePublicIdConstraintsOnIdentities < ActiveRecord::Migration[8.2]
  def up
    backfill_public_ids(Staff)
    backfill_public_ids(User)

    change_column :staffs, :public_id, :string, limit: 21, null: false
    change_column :users, :public_id, :string, limit: 21, null: false

    add_index :staffs, :public_id, unique: true unless index_exists?(:staffs, :public_id)
    add_index :users, :public_id, unique: true unless index_exists?(:users, :public_id)
  end

  def down
    change_column :staffs, :public_id, :string, limit: 255, null: true
    change_column :users, :public_id, :string, limit: 255, null: true
  end

  private

  def backfill_public_ids(model)
    model.reset_column_information
    say_with_time("Ensuring #{model.name} public_id values") do
      model.where(public_id: nil).find_each(batch_size: 100) do |record|
        record.update!(public_id: Nanoid.generate(size: 21))
      end
    end
  end
end
