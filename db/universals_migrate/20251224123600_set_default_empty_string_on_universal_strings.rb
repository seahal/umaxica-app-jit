class SetDefaultEmptyStringOnUniversalStrings < ActiveRecord::Migration[8.2]
  def change
    tables = %i[
      area_occurrences
      domain_occurrences
      email_occurrences
      ip_occurrences
      staff_occurrences
      telephone_occurrences
      user_occurrences
      zip_occurrences
    ]

    tables.each do |table|
      change_column_default table, :body, from: nil, to: ""
      change_column_default table, :public_id, from: nil, to: ""
      change_column_default table, :status_id, from: nil, to: ""
    end
  end
end
