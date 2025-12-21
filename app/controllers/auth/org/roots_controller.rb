module Auth
  module Org
    class RootsController < ApplicationController
      def index
        redirect_to new_auth_org_authentication_path
      end
    end
  end
end
