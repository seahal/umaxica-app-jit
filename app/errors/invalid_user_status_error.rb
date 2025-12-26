# frozen_string_literal: true

class InvalidUserStatusError < StandardError
  # Define a reader to read the invalid status value
  attr_reader :invalid_status

  # As a convention, accept an error message and the invalid status value.
  def initialize(invalid_status:, message: "Invalid user status specified")
    # Call StandardError constructor with super(),
    # and pass the error message you want to display.
    super("#{message}: {invalid_status: \"#{invalid_status}\"}")

    # Let the error object itself hold the invalid status value.
    @invalid_status = invalid_status
  end
end
