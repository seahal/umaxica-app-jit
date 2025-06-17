# frozen_string_literal: true

module Contact
  extend ActiveSupport::Concern

  included do
    # Maximum attempt count
    MAX_ATTEMPT_COUNT ||= 10
    # Cookie expiration period (hours)
    COOKIE_EXPIRE_HOURS ||= 2
    # Cookie prefix
    COOKIE_PREFIX ||= "contact_"
  end

  private

  # Clear all contact-related cookies
  def clear_contact_cookies
    cookies.each do |key, _|
      cookies.delete(key) if key.start_with?(COOKIE_PREFIX)
    end
  end

  # Set non-confidential cookies (with encryption)
  def set_contact_cookie(key, value)
    cookie_key = "#{COOKIE_PREFIX}#{key}"
    cookies.permanent.encrypted[cookie_key] = {
      value: value,
      expires: COOKIE_EXPIRE_HOURS.hours.from_now,
      httponly: true,
      secure: Rails.env.production?, # secure: true only in production environment
      same_site: :lax
    }
    value
  end

  # Get cookie (encrypted)
  def get_contact_cookie(key)
    cookie_key = "#{COOKIE_PREFIX}#{key}"
    cookies.encrypted[cookie_key]
  end

  # Delete cookie
  def delete_contact_cookie(key)
    cookie_key = "#{COOKIE_PREFIX}#{key}"
    cookies.delete(cookie_key)
  end

  # Set all contact-related variables
  def set_contact_session(contact_id: nil, contact_email_address: nil, contact_telephone_number: nil,
                          contact_email_checked: nil, contact_telephone_checked: nil,
                          contact_otp_private_key: nil, contact_expires_in: nil, contact_hotp_counter: nil)
    # Store non-confidential information in cookies
    set_contact_cookie(:id, contact_id)
    set_contact_cookie(:email_checked, contact_email_checked)
    set_contact_cookie(:telephone_checked, contact_telephone_checked)
    set_contact_cookie(:expires_in, contact_expires_in&.to_i&.to_s)

    # Store confidential information in Redis (memorize)
    memorize[:contact_email_address] = contact_email_address
    memorize[:contact_telephone_number] = contact_telephone_number
    memorize[:contact_otp_private_key] = contact_otp_private_key
  end

  # Clear contact state
  def clear_contact_session
    # Clear cookies
    clear_contact_cookies

    # Clear confidential information in Redis
    memorize[:contact_email_address] = nil
    memorize[:contact_telephone_number] = nil
    memorize[:contact_otp_private_key] = nil
  end

  # Check if all contact information is set
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

  # Display error page
  def show_error_page
    clear_contact_session
    render template: "www/app/inquiries/error", status: :unprocessable_entity and return
  end

  # Initialize cookies
  def initialize_contact_cookies
    get_contact_cookie(:count) || set_contact_cookie(:count, 0)
    get_contact_cookie(:expires_in) || set_contact_cookie(:expires_in, COOKIE_EXPIRE_HOURS.hours.from_now.to_i.to_s)
  end

  # Cloudflare Turnstile verification
  def cloudflare_valid?
    cloudflare_turnstile_validation["success"]
  end

  # Generate stateless OTP (without storing secret key)
  def generate_stateless_otp(master_key, context)
    # Use time window (e.g., 30-minute intervals) - time-based with expiration
    time_window = (Time.now.to_i / (30 * 60)).to_i
    data_to_hash = "#{context}:#{time_window}"

    # Calculate HMAC-SHA256 using master key
    hmac = OpenSSL::HMAC.digest("SHA256", master_key, data_to_hash)

    # Convert to 6-digit numeric code (treat first 4 bytes as integer, modulo to 6 digits)
    code = hmac[0...4].unpack("L")[0] % 1_000_000

    # Zero-pad to 6 digits
    "%06d" % code
  end

  # Verify OTP (stateless)
  def verify_stateless_otp(master_key, context, provided_code)
    # Check codes for current and previous time windows (timing issue countermeasure)
    current_window = (Time.now.to_i / (30 * 60)).to_i

    # Check with current and previous two windows
    [ current_window, current_window - 1 ].any? do |window|
      data_to_hash = "#{context}:#{window}"
      hmac = OpenSSL::HMAC.digest("SHA256", master_key, data_to_hash)
      code = hmac[0...4].unpack("L")[0] % 1_000_000
      formatted_code = "%06d" % code

      # Use constant-time comparison for secure comparison
      ActiveSupport::SecurityUtils.secure_compare(formatted_code, provided_code)
    end
  end

  # Handle invalid input
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

  # Increment attempt counter
  def increment_attempt_counter
    count = get_contact_cookie(:count).to_i + 1
    set_contact_cookie(:count, count)
    # Clear session if too many attempts (brute force attack countermeasure)
    clear_contact_session if count >= MAX_ATTEMPT_COUNT
  end

  # Validate session for edit page
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

  # Validate session for update page
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

  # Validate session for show page
  def validate_session_for_show
    valid_show_state? ? nil : show_error_page
  end

  # Check if show page state is valid
  def valid_show_state?
    [
      params[:id].present?,
      get_contact_cookie(:id).present?,
      get_contact_cookie(:id) != params[:id],
      get_contact_cookie(:email_checked) == false,
      get_contact_cookie(:telephone_checked) == true
    ].all?
  end

  # Check if session is not expired
  def session_not_expired?
    expires_in = get_contact_cookie(:expires_in).to_i
    result = expires_in > Time.now.to_i
    # Clear session if expired
    clear_contact_session unless result
    result
  end

  # Save contact with verified data
  def save_contact_with_verified_data
    @service_site_contact.id = gen_original_uuid
    @service_site_contact.email_address = memorize[:contact_email_address]
    @service_site_contact.telephone_number = memorize[:contact_telephone_number]
    @service_site_contact.ip_address = secure_remote_ip
    @service_site_contact.save!

    set_contact_cookie(:email_checked, false)
  end

  # Get secure remote IP
  def secure_remote_ip
    # Properly handle X-Forwarded-For header
    forwarded = request.env["HTTP_X_FORWARDED_FOR"]
    if forwarded.present? && trusted_proxy?(request.remote_ip)
      # Get first IP address (if comma-separated)
      forwarded.split(",").first.strip
    else
      request.remote_ip
    end
  end

  # Check if proxy is trusted
  def trusted_proxy?(ip)
    # Check if within private IP address ranges
    private_ranges = [
      IPAddr.new("10.0.0.0/8"),
      IPAddr.new("172.16.0.0/12"),
      IPAddr.new("192.168.0.0/16")
    ]

    private_ranges.any? { |range| range.include?(ip) }
  rescue
    false
  end

  # Method to verify that contact email has been verified
  def verify_contact_email(contact_id, provided_code)
    # Check if code sent by user is valid
    if get_contact_cookie(:id) == contact_id &&
       memorize[:contact_email_address].present? &&
       session_not_expired?

      # Stateless OTP verification
      master_key = Rails.application.secrets.secret_key_base
      email_address = memorize[:contact_email_address]
      telephone_number = memorize[:contact_telephone_number]
      user_specific_data = "#{contact_id}:#{email_address}:#{telephone_number}"
      email_context = "email:#{user_specific_data}"

      if verify_stateless_otp(master_key, email_context, provided_code)
        # Update session and authentication state
        set_contact_cookie(:email_checked, true)
        set_contact_cookie(:expires_in, COOKIE_EXPIRE_HOURS.hours.from_now.to_i.to_s)
        return true
      end
    end

    false
  end

  # Similar method for SMS verification
  def verify_contact_telephone(contact_id, provided_code)
    if get_contact_cookie(:id) == contact_id &&
       memorize[:contact_telephone_number].present? &&
       session_not_expired?

      # Stateless OTP verification
      master_key = Rails.application.secrets.secret_key_base
      email_address = memorize[:contact_email_address]
      telephone_number = memorize[:contact_telephone_number]
      user_specific_data = "#{contact_id}:#{email_address}:#{telephone_number}"
      sms_context = "sms:#{user_specific_data}"

      if verify_stateless_otp(master_key, sms_context, provided_code)
        # Update session and authentication state
        set_contact_cookie(:telephone_checked, true)
        set_contact_cookie(:expires_in, COOKIE_EXPIRE_HOURS.hours.from_now.to_i.to_s)
        return true
      end
    end

    false
  end
end
