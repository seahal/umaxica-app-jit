# frozen_string_literal: true

class Apex::App::Configuration::RootsController < Apex::App::ApplicationController
  auth_required!
  prepend_before_action :transparent_refresh_access_token, unless: -> { request.format.json? }

  def show
  end
end
