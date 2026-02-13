# frozen_string_literal: true

class Apex::Org::Configuration::RootsController < Apex::Org::ApplicationController
  auth_required!
  prepend_before_action :transparent_refresh_access_token, unless: -> { request.format.json? }

  def show
  end
end
