# typed: false
# frozen_string_literal: true

module Foundation
  module Edge
    module V0
      module MessagesEndpoint
        extend ActiveSupport::Concern

        private

        def ensure_json_request
          return if request.format.json?

          render json: { error: "not_acceptable" }, status: :not_acceptable
        end

        def set_message_id
          @message_id = params[:id].to_s
        end

        def message_payload(id)
          { id: id, type: "message", attributes: {} }
        end
      end
    end
  end
end
