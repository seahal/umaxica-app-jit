module Sign
  module Org
    class RootsController < ApplicationController
      def index
        redirect_to new_sign_org_authentication_path
      end
    end
  end
end
