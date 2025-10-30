class CreateContactCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :contact_categories, id: :uuid do |t|
      t.string :description

      t.timestamps
    end
  end
end
