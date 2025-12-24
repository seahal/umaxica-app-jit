module Csrf
  extend ActiveSupport::Concern

  def show
    response.set_header("Cache-Control", "no-store")
    # Client should call with credentials: "include" and send X-CSRF-Token on write requests.
    render json: { csrf_token: form_authenticity_token }
  end
end
