# typed: false
# frozen_string_literal: true

module Dbsc
  module HeaderParser
    module_function

    def string_value(value)
      string = value.to_s.strip
      return if string.blank?

      if string.start_with?("\"") && string.end_with?("\"")
        string[1...-1]
      else
        string
      end
    end
  end
end
