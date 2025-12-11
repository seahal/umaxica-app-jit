class CreateOrganizations < ActiveRecord::Migration[8.2]
  def change
    create_table :organizations, id: :uuid do |t|
      t.string :name
      t.string :domain
      t.uuid :parent_organization

      t.timestamps
    end
  end
end
