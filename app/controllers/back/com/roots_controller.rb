module Back
  module Com
    class RootsController < ApplicationController
      def index
        redirect_to "https://#{ENV['BACK_CORPORATE_URL']}", allow_other_host: true
      end
    end
  end
end
