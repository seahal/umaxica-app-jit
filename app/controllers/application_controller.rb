# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ::Preference::Base

  protect_from_forgery with: :exception
end
