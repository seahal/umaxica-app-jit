class CreateStaffs   < ActiveRecord::Migration[7.2]
  def change
    # FIXME: need hashed partition.
    create_table :staffs, id: :uuid do |t|
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at

    t.timestamps
    end
  end
end
