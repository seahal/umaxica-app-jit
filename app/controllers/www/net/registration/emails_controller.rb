module Net
  module Registration
    class EmailsController < ApplicationController
      def new
        @user_email = UserEmail.new
      end

      def create; end
    end
  end
end
