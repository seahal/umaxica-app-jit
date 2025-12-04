module Back
  module Org
    class RootsController < ApplicationController
      def index
        redirect_to "https://#{ENV['BACK_STAFF_URL']}", allow_other_host: true
      end
    end
  end
end
