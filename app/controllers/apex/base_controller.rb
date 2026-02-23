# typed: false
# frozen_string_literal: true

module Apex
  module BaseController
    extend ActiveSupport::Concern

    included do
      include ::Preference::Global

      before_action :enforce_required_ri!
    end

    private

    def enforce_required_ri!
      ensure_required_ri!
    end
  end
end
