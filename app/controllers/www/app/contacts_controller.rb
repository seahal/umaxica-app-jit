module Www::App
  class ContactsController < ApplicationController
    include ::Cloudflare
    include ::Contact
    include ::Rotp
    include ::Common
    include ::Memorize

    before_action :initialize_contact_cookies, only: [ :create, :edit ]
    before_action :validate_session_for_edit, only: [ :edit ]
    before_action :validate_session_for_update, only: [ :update ]
    before_action :validate_session_for_show, only: [ :show ]

    def new
      clear_contact_session
      session[:contact_count] ||= 0
      session[:contact_expires_in] = 2.hours.from_now
      @service_site_contact = ServiceSiteContact.new
    end

    def create
      @service_site_contact = ServiceSiteContact.new(get_contact_cookie(:id))
      if @service_site_contact.valid? && cloudflare_valid?
        process_contact_creation
        redirect_to new_www_app_contact_email_url(get_contact_cookie(:id))
      else
        handle_invalid_create
      end
    end

    def edit
      @service_site_contact = ServiceSiteContact.new
    end

    def update
      @service_site_contact = ServiceSiteContact.new(update_params)

      if @service_site_contact.valid?
        save_contact_with_verified_data
        redirect_to www_app_contact_url(@service_site_contact.id)
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def show
      if valid_show_state?
        session[:contact_count] = 0
        clear_contact_session
      else
        show_error_page
      end
    end

    private
      # Only allow a list of trusted parameters through.
      # Only allow a list of trusted parameters through.
      def create_params
        params.expect(service_site_contact: [ :confirm_policy, :telephone_number, :email_address ])
      end

    # Only allow a list of trusted parameters through.
    def update_params
      params.expect(service_site_contact: [ :title, :description ])
    end


    # コンタクト作成処理
    def process_contact_creation
      clear_contact_session
      contact_id = SecureRandom.uuid_v4.to_s

      # 秘密鍵はセッションではなくTOTPシードをHMACで生成
      master_key = "__???"
      email_address = @service_site_contact.email_address
      telephone_number = @service_site_contact.telephone_number
      user_specific_data = "#{contact_id}:#{email_address}:#{telephone_number}"

      # 状態の設定（機密情報はRedisに、非機密情報はCookieに）
      set_contact_session(
        contact_id: contact_id,
        contact_email_checked: false,
        contact_telephone_checked: false,
        contact_expires_in: COOKIE_EXPIRE_HOURS.hours.from_now,
        contact_email_address: email_address,
        contact_telephone_number: telephone_number
      )

      set_contact_cookie(:count, 0)

      # 秘密鍵を保存せずにOTPを生成して送信
      send_verification_codes_secure(master_key, user_specific_data)
    end

    # セキュアなOTP検証コードの送信
    def send_verification_codes_secure(master_key, user_specific_data)
      # メール用とSMS用に異なるコンテキストでOTPを生成
      email_context = "email:#{user_specific_data}"
      sms_context = "sms:#{user_specific_data}"

      # メール検証用コード
      email_code = generate_stateless_otp(master_key, email_context)
      if Rails.env.test?
        set_contact_cookie(:email_pass_code, email_code)
      else
        send_otp_code_using_email(
          pass_code: email_code,
          email_address: memorize[:contact_email_address]
        )
      end

      # SMS検証用コード
      sms_code = generate_stateless_otp(master_key, sms_context)
      if Rails.env.test?
        set_contact_cookie(:telephone_pass_code, sms_code)
      else
        send_otp_code_using_sms(
          pass_code: sms_code,
          telephone_number: memorize[:contact_telephone_number]
        )
      end
    end
  end
end
