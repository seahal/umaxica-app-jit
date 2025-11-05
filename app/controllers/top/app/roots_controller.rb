module Top
  module App
    class RootsController < ApplicationController
      def index
        redirect_to "https://#{ENV['TOP_SERVICE_URL']}", allow_other_host: true
      end
    end
  end
end
