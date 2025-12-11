class CreateOrganizations < ActiveRecord::Migration[8.2]
  def change
    create_table :organizations, id: :uuid do |t|
      t.string :name
      t.string :domain
      t.uuid :parent_organization

      t.timestamps
    end

    add_index :organizations, :parent_organization
    add_index :organizations, :domain, unique: true, where: "domain IS NOT NULL"
    add_foreign_key :organizations, :organizations, column: :parent_organization
  end
end
