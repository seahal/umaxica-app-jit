module Top
  module Org
    class RootsController < ApplicationController
      def index
        render plain: 'top app root'
      end
    end
  end
end
