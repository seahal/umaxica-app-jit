# typed: false
# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ::Fuse
  include ::Finisher

  before_action :check_fuse!
  append_after_action :finish_request

  protect_from_forgery with: :exception
end
