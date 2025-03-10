module Www
  module Com
    class ContactsController < ApplicationController
      def new
        render plain: localize_time(Time.now)
      end

      def create
      end
    end
  end
end
