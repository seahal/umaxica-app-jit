# frozen_string_literal: true

module Sign
  module BaseController
    extend ActiveSupport::Concern

    included do
      include ::Preference::Global
      include ::ParamContext

      before_action :resolve_param_context
      before_action :enforce_required_ri!
    end

    private

    def enforce_required_ri!
      ensure_required_ri!
    end

    def default_url_options
      base_options = super || {}
      base_options.merge(ri: required_ri).merge(optional_context_params_for_urls)
    end
  end
end
