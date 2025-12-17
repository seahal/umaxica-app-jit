# frozen_string_literal: true

module ApplicationHelper
  # User authentication helpers
  def logged_in?
    current_user.present?
  end

  def current_user
    # rubocop:disable Rails/HelperInstanceVariable
    return @current_user if defined?(@current_user)
    # rubocop:enable Rails/HelperInstanceVariable
    nil
  end
end
