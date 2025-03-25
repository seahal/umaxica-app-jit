# frozen_string_literal: true

module Health
  extend ActiveSupport::Concern

  def show
    expires_in 1.second, public: true # this page wouldn't include private data

    # FIXME: much more validations requires
    if !!User.connection.execute("SELECT 1 FROM users LIMIT 1")
      @title = "OK"
      respond_to do |format|
        format.json { render json: { status: @title }, status: 200 }
        format.html { render plain: @title, status: 200 }
      end
    else
      @title = "NG"
      respond_to do |format|
        format.json { render json: { status: @title }, status: 503 }
        format.html { render plain: @title, status: 503 }
      end
    end
  end
end
