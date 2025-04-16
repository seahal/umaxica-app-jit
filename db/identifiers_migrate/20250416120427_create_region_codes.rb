class CreateRegionCodes < ActiveRecord::Migration[8.1]
  def change
    create_table :region_codes, id: :string do |t|
    end
  end
end
