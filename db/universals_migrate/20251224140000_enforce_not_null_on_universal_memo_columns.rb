class EnforceNotNullOnUniversalMemoColumns < ActiveRecord::Migration[8.2]
  def change
    # All occurrence tables have memo columns that should not be null
    tables = %w[
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
      reversible do |dir|
        dir.up do
          # First, update existing NULL values to empty string
          execute "UPDATE #{table} SET memo = '' WHERE memo IS NULL"
        end
      end

      # Then change column default and add NOT NULL constraint
      change_column_null table, :memo, false, ''
      change_column_default table, :memo, from: nil, to: ''
    end
  end
end
