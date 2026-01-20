# frozen_string_literal: true

class Owner::Com::TokensController < Owner::BaseController
  # GET /owner/com/token
  def show
    # TODO: return the current token control state
    # Example:
    # - token_version (access token invalidation generation)
    # - last_access_reset_at
    # - refresh_allowed (optional)
    #
    # TODO: consider returning a summary of the last action so the audit log can be traced
    render json: { surface: "com", token_version: 1 }
  end

  # PATCH /owner/com/token
  def update
    # TODO: treat emergency operations as state updates
    #
    # Supported operations (final list can be decided later):
    # - token[action]=access_reset  => token_version++ (invalidate past access tokens)
    # - token[action]=refresh_freeze => refresh_allowed=false (optional)
    #
    # TODO: delegate actual work to a service (keep the controller thin)
    # - TokenEmergencyService.call!(surface: :com, action:, reason:, actor:)
    # - To reflect invalidation immediately
    #   - include token_version (tv) in JWT and require a match during verification
    #   - or use sid revoke / denylist (design dependent)
    #
    # TODO: audit log (reason should be required)
    #
    # TODO: clarify the impact scope
    # - access only?
    # - block refresh as well?
    # - cover Web/Native/API surfaces
    head :no_content
  end

  private

  def token_params
    # TODO: strong params (finalize tomorrow)
    # params.require(:token).permit(:action, :reason)
    params.fetch(:token, {}).permit(:action, :reason)
  end
end
