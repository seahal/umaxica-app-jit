class RenameTelepyhonesToTelephones < ActiveRecord::Migration[8.1]
  def change
    rename_table :corporate_site_contact_telepyhones, :corporate_site_contact_telephones
  end
end
