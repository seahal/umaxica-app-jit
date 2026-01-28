# frozen_string_literal: true

class Sign::Org::Edge::V1::Token::ChecksController < Sign::Org::Edge::V1::BaseController
  skip_before_action :set_preferences_cookie
  skip_before_action :transparent_refresh_access_token

  def show
    response.set_header("Cache-Control", "no-store")

    authenticated = logged_in?
    body =
      if authenticated
        {
          authenticated: true,
          type: resource_type,
          id: current_resource.id,
          sid: current_session_public_id
        }
      else
        { authenticated: false }
      end

    render json: body, status: authenticated ? :ok : :unauthorized
  end
end
