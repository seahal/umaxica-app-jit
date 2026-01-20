# frozen_string_literal: true

class Owner::Com::OutagesController < Owner::BaseController
  # GET /owner/com/outage
  def show
    # TODO: return the current outage state
    # - status: running / maintenance / stopped (optional)
    # - message: user-facing text (consider i18n)
    # - reason: internal use (audit)
    # - enabled_at/disabled_at, enabled_by
    #
    # Implementation ideas:
    # - DB: read the single outage_states row where surface=com
    # - Redis/FeatureFlag: read "outage:com" (audit log stored elsewhere)
    render json: { surface: "com", status: "running" }
  end

  # PATCH /owner/com/outage
  def update
    # TODO: toggle emergency maintenance (state update)
    # - accept outage_params[:status] (maintenance/running etc)
    # - allow updating message / reason (reason should be required)
    #
    # TODO: audit log
    # - actor (who performed the action)
    # - surface=com
    # - before/after state
    # - reason (required)
    #
    # TODO: propagation strategy
    # - Web: serve 503 or a maintenance page
    # - API: 503 + optional Retry-After header
    #
    # TODO: ensure owner namespace is unaffected (implement in middleware/concern)
    #
    # Example: OutageService.update!(surface: :com, attrs: outage_params, actor: current_owner)
    head :no_content
  end

  private

  def outage_params
    # TODO: strong params (decide on form/JSON shape later)
    # params.require(:outage).permit(:status, :message, :reason)
    params.fetch(:outage, {}).permit(:status, :message, :reason)
  end
end
