module Www
  module Com
    class RobotsController < ApplicationController
      def show
        respond_to do |format|
          expires_in 1.hour, public: true # this page wouldn't include private data

          # htmlでリクエストされたときshow.html.erbをレンダリング｡ブロックは省略可
          format.text { render :show }
        end
      end
    end
  end
end
