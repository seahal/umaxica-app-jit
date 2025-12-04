module Back
  module App
    class RootsController < ApplicationController
      def index
        redirect_to "https://#{ENV['BFF_SERVICE_URL']}", allow_other_host: true
      end
    end
  end
end
