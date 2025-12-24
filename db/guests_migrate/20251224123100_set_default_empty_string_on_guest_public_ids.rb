class SetDefaultEmptyStringOnGuestPublicIds < ActiveRecord::Migration[8.2]
  def change
    columns = {
      app_contact_topics: %i[public_id],
      app_contacts: %i[public_id],
      com_contact_topics: %i[public_id],
      com_contacts: %i[public_id],
      org_contact_topics: %i[public_id],
      org_contacts: %i[public_id]
    }

    columns.each do |table, cols|
      cols.each do |col|
        change_column_default table, col, from: nil, to: ""
      end
    end
  end
end
