# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Fuse

  protect_from_forgery with: :exception
end
