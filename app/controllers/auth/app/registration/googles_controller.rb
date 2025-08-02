module Auth
  module App
    module Registration
      class GooglesController < ApplicationController
        def new
          redirect_to "/auth/google_oauth2", allow_other_host: true
        end

        def create
          auth_hash = request.env['omniauth.auth']
          
          if auth_hash.present?
            # Google OAuth認証成功時の処理
            @user_info = {
              provider: auth_hash.provider,
              uid: auth_hash.uid,
              email: auth_hash.info.email,
              name: auth_hash.info.name,
              image: auth_hash.info.image
            }
            
            # ここでユーザー登録処理を実装
            # 例: User.find_or_create_by(email: @user_info[:email]) do |user|
            #       user.name = @user_info[:name]
            #       user.provider = @user_info[:provider]
            #       user.uid = @user_info[:uid]
            #     end
            
            render :success
          else
            # 認証失敗時の処理
            flash[:error] = "アクセスをブロック: 認証エラーです"
            redirect_to new_auth_app_registration_path
          end
        end
      end
    end
  end
end
