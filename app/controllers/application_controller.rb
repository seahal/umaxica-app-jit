# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ::Fuse
  include ::Finisher

  protect_from_forgery with: :exception
end
