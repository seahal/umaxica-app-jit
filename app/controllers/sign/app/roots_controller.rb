module Sign
  module App
    class RootsController < ApplicationController
      def index
        redirect_to new_sign_app_registration_path
      end
    end
  end
end
