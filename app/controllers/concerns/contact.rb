# frozen_string_literal: true

module Contact
  extend ActiveSupport::Concern

  included do
    # 最大試行回数
    MAX_ATTEMPT_COUNT ||= 10
    # Cookieの有効期間（時間）
    COOKIE_EXPIRE_HOURS ||= 2
    # Cookieプレフィックス
    COOKIE_PREFIX ||= "contact_"
  end

  private

  # すべてのコンタクト関連Cookieをクリア
  def clear_contact_cookies
    cookies.each do |key, _|
      cookies.delete(key) if key.start_with?(COOKIE_PREFIX)
    end
  end

  # 非機密Cookieの設定（暗号化あり）
  def set_contact_cookie(key, value)
    cookie_key = "#{COOKIE_PREFIX}#{key}"
    cookies.permanent.encrypted[cookie_key] = {
      value: value,
      expires: COOKIE_EXPIRE_HOURS.hours.from_now,
      httponly: true,
      secure: Rails.env.production?, # 本番環境のみsecure: true
      same_site: :lax
    }
    value
  end

  # Cookieの取得（暗号化）
  def get_contact_cookie(key)
    cookie_key = "#{COOKIE_PREFIX}#{key}"
    cookies.encrypted[cookie_key]
  end

  # Cookieの削除
  def delete_contact_cookie(key)
    cookie_key = "#{COOKIE_PREFIX}#{key}"
    cookies.delete(cookie_key)
  end

  # すべてのコンタクト関連変数をセット
  def set_contact_session(contact_id: nil, contact_email_address: nil, contact_telephone_number: nil,
                          contact_email_checked: nil, contact_telephone_checked: nil,
                          contact_otp_private_key: nil, contact_expires_in: nil, contact_hotp_counter: nil)
    # 非機密情報はCookieに保存
    set_contact_cookie(:id, contact_id)
    set_contact_cookie(:email_checked, contact_email_checked)
    set_contact_cookie(:telephone_checked, contact_telephone_checked)
    set_contact_cookie(:expires_in, contact_expires_in&.to_i&.to_s)

    # 機密情報はRedisに保存（memorize）
    memorize[:contact_email_address] = contact_email_address
    memorize[:contact_telephone_number] = contact_telephone_number
    memorize[:contact_otp_private_key] = contact_otp_private_key
  end

  # 連絡先の状態をクリア
  def clear_contact_session
    # Cookieをクリア
    clear_contact_cookies

    # Redis内の機密情報もクリア
    memorize[:contact_email_address] = nil
    memorize[:contact_telephone_number] = nil
    memorize[:contact_otp_private_key] = nil
  end

  # すべてのコンタクト情報が設定されているか確認
  def check_all_contact_session_not_nil?
    [
      get_contact_cookie(:id),
      get_contact_cookie(:email_checked),
      get_contact_cookie(:telephone_checked),
      get_contact_cookie(:expires_in),
      memorize[:contact_otp_private_key],
      memorize[:contact_email_address],
      memorize[:contact_telephone_number]
    ].all?(&:present?)
  end

  # エラーページを表示
  def show_error_page
    clear_contact_session
    render template: "www/app/contacts/error", status: :unprocessable_entity and return
  end

  # Cookieの初期化
  def initialize_contact_cookies
    get_contact_cookie(:count) || set_contact_cookie(:count, 0)
    get_contact_cookie(:expires_in) || set_contact_cookie(:expires_in, COOKIE_EXPIRE_HOURS.hours.from_now.to_i.to_s)
  end

  # Cloudflareターンスタイル検証
  def cloudflare_valid?
    cloudflare_turnstile_validation["success"]
  end

  # ステートレスOTP生成（秘密鍵を保存しない）
  def generate_stateless_otp(master_key, context)
    # 時間窓を使用（例: 30分単位）- 時間ベースにして有効期限を設ける
    time_window = (Time.now.to_i / (30 * 60)).to_i
    data_to_hash = "#{context}:#{time_window}"

    # マスターキーを使ってHMAC-SHA256を計算
    hmac = OpenSSL::HMAC.digest("SHA256", master_key, data_to_hash)

    # 6桁の数値コードに変換（最初の4バイトを整数として扱い、モジュロ処理で6桁に）
    code = hmac[0...4].unpack("L")[0] % 1_000_000

    # 0埋めして6桁に揃える
    "%06d" % code
  end

  # OTPの検証（ステートレス）
  def verify_stateless_otp(master_key, context, provided_code)
    # 現在の時間窓と直前の時間窓のコードを確認（タイミング問題対策）
    current_window = (Time.now.to_i / (30 * 60)).to_i

    # 現在と直前の2つの窓でチェック
    [ current_window, current_window - 1 ].any? do |window|
      data_to_hash = "#{context}:#{window}"
      hmac = OpenSSL::HMAC.digest("SHA256", master_key, data_to_hash)
      code = hmac[0...4].unpack("L")[0] % 1_000_000
      formatted_code = "%06d" % code

      # 定数時間比較を使用して安全に比較
      ActiveSupport::SecurityUtils.secure_compare(formatted_code, provided_code)
    end
  end

  # 無効な入力の処理
  def handle_invalid_create
    increment_attempt_counter

    unless cloudflare_valid?
      @service_site_contact.errors.add(
        :base, :invalid,
        message: t("model.concern.cloudflare.invalid_input")
      )
    end

    clear_contact_session
    render :new, status: :unprocessable_entity
  end

  # 試行回数のインクリメント
  def increment_attempt_counter
    count = get_contact_cookie(:count).to_i + 1
    set_contact_cookie(:count, count)
    # 試行回数が多すぎる場合はセッションをクリア（ブルートフォース攻撃対策）
    clear_contact_session if count >= MAX_ATTEMPT_COUNT
  end

  # 編集ページのセッション検証
  def validate_session_for_edit
    valid_session = [
      params[:id].present?,
      get_contact_cookie(:id).present?,
      get_contact_cookie(:id) == params[:id],
      get_contact_cookie(:email_checked),
      get_contact_cookie(:telephone_checked),
      session_not_expired?,
      (get_contact_cookie(:count).to_i || 0) < MAX_ATTEMPT_COUNT
    ].all?

    show_error_page unless valid_session
  end

  # 更新ページのセッション検証
  def validate_session_for_update
    valid_session = [
      params[:id].present?,
      get_contact_cookie(:id).present?,
      get_contact_cookie(:id) == params[:id],
      get_contact_cookie(:email_checked) == true,
      get_contact_cookie(:telephone_checked) == true,
      session_not_expired?
    ].all?

    render :edit, status: :unprocessable_entity unless valid_session
  end

  # 表示ページのセッション検証
  def validate_session_for_show
    valid_show_state? ? nil : show_error_page
  end

  # 表示ページの状態が有効か確認
  def valid_show_state?
    [
      params[:id].present?,
      get_contact_cookie(:id).present?,
      get_contact_cookie(:id) != params[:id],
      get_contact_cookie(:email_checked) == false,
      get_contact_cookie(:telephone_checked) == true
    ].all?
  end

  # セッションが期限切れでないか確認
  def session_not_expired?
    expires_in = get_contact_cookie(:expires_in).to_i
    result = expires_in > Time.now.to_i
    # 期限切れの場合はセッションをクリア
    clear_contact_session unless result
    result
  end

  # 検証済みデータで連絡先を保存
  def save_contact_with_verified_data
    @service_site_contact.id = gen_original_uuid
    @service_site_contact.email_address = memorize[:contact_email_address]
    @service_site_contact.telephone_number = memorize[:contact_telephone_number]
    @service_site_contact.ip_address = secure_remote_ip
    @service_site_contact.save!

    set_contact_cookie(:email_checked, false)
  end

  # 安全なリモートIP取得
  def secure_remote_ip
    # X-Forwarded-For ヘッダーを適切に処理
    forwarded = request.env["HTTP_X_FORWARDED_FOR"]
    if forwarded.present? && trusted_proxy?(request.remote_ip)
      # 最初のIPアドレスを取得（カンマで区切られている場合）
      forwarded.split(",").first.strip
    else
      request.remote_ip
    end
  end

  # 信頼できるプロキシかどうか確認
  def trusted_proxy?(ip)
    # プライベートIPアドレス範囲かどうかをチェック
    private_ranges = [
      IPAddr.new("10.0.0.0/8"),
      IPAddr.new("172.16.0.0/12"),
      IPAddr.new("192.168.0.0/16")
    ]

    private_ranges.any? { |range| range.include?(ip) }
  rescue
    false
  end

  # コンタクトメールが検証されたことを確認するメソッド
  def verify_contact_email(contact_id, provided_code)
    # ユーザーから送信されたコードが有効か確認
    if get_contact_cookie(:id) == contact_id &&
       memorize[:contact_email_address].present? &&
       session_not_expired?

      # ステートレスOTPの検証
      master_key = Rails.application.secrets.secret_key_base
      email_address = memorize[:contact_email_address]
      telephone_number = memorize[:contact_telephone_number]
      user_specific_data = "#{contact_id}:#{email_address}:#{telephone_number}"
      email_context = "email:#{user_specific_data}"

      if verify_stateless_otp(master_key, email_context, provided_code)
        # セッションを更新して認証状態を更新
        set_contact_cookie(:email_checked, true)
        set_contact_cookie(:expires_in, COOKIE_EXPIRE_HOURS.hours.from_now.to_i.to_s)
        return true
      end
    end

    false
  end

  # SMS検証用の同様のメソッド
  def verify_contact_telephone(contact_id, provided_code)
    if get_contact_cookie(:id) == contact_id &&
       memorize[:contact_telephone_number].present? &&
       session_not_expired?

      # ステートレスOTPの検証
      master_key = Rails.application.secrets.secret_key_base
      email_address = memorize[:contact_email_address]
      telephone_number = memorize[:contact_telephone_number]
      user_specific_data = "#{contact_id}:#{email_address}:#{telephone_number}"
      sms_context = "sms:#{user_specific_data}"

      if verify_stateless_otp(master_key, sms_context, provided_code)
        # セッションを更新して認証状態を更新
        set_contact_cookie(:telephone_checked, true)
        set_contact_cookie(:expires_in, COOKIE_EXPIRE_HOURS.hours.from_now.to_i.to_s)
        return true
      end
    end

    false
  end
end
