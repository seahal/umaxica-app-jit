module Core
  module Com
    module V1
      class CsrfController < ApplicationController
        def show
          render json: { csrf_token: form_authenticity_token }
        end
      end
    end
  end
end
