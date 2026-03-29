# typed: false
# frozen_string_literal: true

class Sign::App::Edge::V0::Token::DbscRegistrationsController < Sign::App::ApplicationController
  include Sign::EdgeV0JsonApi
  include Sign::DbscRegistrationEndpoint

  public_strict!
  skip_before_action :set_preferences_cookie
  skip_before_action :transparent_refresh_access_token

  private

  def dbsc_registration_url
    sign_app_edge_v0_token_dbsc_registration_url
  end
end
