# typed: false
# frozen_string_literal: true

# Ensure PostgreSQL UUID primary keys default to uuidv7() so records are ordered by time.
ActiveSupport.on_load(:active_record) do
  module UUIDv7PrimaryKey
    define_method(:primary_key) do |name, type = :primary_key, **options|
      if type == :uuid
        options[:default] = options.fetch(:default, "uuidv7()")
      end

      super(name, type, **options)
    end
  end

  ActiveRecord::ConnectionAdapters::PostgreSQL::ColumnMethods.prepend(UUIDv7PrimaryKey)
end
