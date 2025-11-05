module Top
  module Com
    class RootsController < ApplicationController
      def index
        render plain: 'top com root'
      end
    end
  end
end
