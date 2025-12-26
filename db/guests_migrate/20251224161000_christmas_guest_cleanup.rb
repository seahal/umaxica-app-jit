class ChristmasGuestCleanup < ActiveRecord::Migration[8.2]
  def change
    # App
    set_defaults_and_nulls(:app_contact_emails, string_cols: [:token_digest, :verifier_digest], time_cols: [:token_expires_at, :verifier_expires_at])
    set_defaults_and_nulls(:app_contact_telephones, string_cols: [:verifier_digest], time_cols: [:verifier_expires_at])
    set_defaults_and_nulls(:app_contact_topics, string_cols: [:otp_digest], time_cols: [:otp_expires_at])

    # Com
    set_defaults_and_nulls(:com_contact_emails, string_cols: %i(token_digest verifier_digest hotp_secret), time_cols: [:token_expires_at, :verifier_expires_at], int_cols: [:hotp_counter])
    set_defaults_and_nulls(:com_contact_telephones, string_cols: [:verifier_digest, :hotp_secret], time_cols: [:verifier_expires_at], int_cols: [:hotp_counter])
    set_defaults_and_nulls(:com_contact_topics, string_cols: [:otp_digest, :description], time_cols: [:otp_expires_at])

    # Org
    set_defaults_and_nulls(:org_contact_emails, string_cols: [:token_digest, :verifier_digest], time_cols: [:token_expires_at, :verifier_expires_at])
    set_defaults_and_nulls(:org_contact_telephones, string_cols: [:verifier_digest], time_cols: [:verifier_expires_at])
    set_defaults_and_nulls(:org_contact_topics, string_cols: [:otp_digest], time_cols: [:otp_expires_at])
  end

  private

  def set_defaults_and_nulls(table, string_cols: [], time_cols: [], int_cols: [])
    string_cols.each do |col|
      up_only { execute("UPDATE #{table} SET #{col} = '' WHERE #{col} IS NULL") }
      change_column_default table, col, from: nil, to: ""
      change_column_null table, col, false
    end

    time_cols.each do |col|
      up_only { execute("UPDATE #{table} SET #{col} = '-infinity' WHERE #{col} IS NULL") }
      change_column_default table, col, from: nil, to: -Float::INFINITY
      change_column_null table, col, false
    end

    int_cols.each do |col|
      up_only { execute("UPDATE #{table} SET #{col} = 0 WHERE #{col} IS NULL") }
      change_column_default table, col, from: nil, to: 0
      change_column_null table, col, false
    end
  end
end
