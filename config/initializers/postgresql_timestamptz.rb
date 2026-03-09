# typed: false
# frozen_string_literal: true

# Use timestamp with time zone (timestamptz) for all new datetime columns.
# Existing columns were converted via migrations.
ActiveSupport.on_load(:active_record_postgresqladapter) do
  self.datetime_type = :timestamptz
end
