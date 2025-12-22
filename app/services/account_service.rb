# AccountService provides a polymorphic interface for User and Staff models
# This allows treating both types uniformly while maintaining their distinct behaviors
#
# @example Basic usage
#   user = User.first
#   account = AccountService.new(user)
#   account.user? # => true
#   account.emails # => user.emails
#
# @example Finding by email
#   account = AccountService.find_by_email("user@example.com")
#   account.accountable # => User or Staff instance
#
class AccountService
  attr_reader :accountable, :type

  # Delegate common methods to the underlying User or Staff model
  delegate :id, :created_at, :updated_at, :webauthn_id,
           :persisted?, :new_record?, :destroyed?,
           to: :accountable

  # Initialize a new AccountService wrapper
  #
  # @param accountable [User, Staff] The underlying model instance
  # @raise [ArgumentError] if accountable is not User or Staff
  def initialize(accountable)
    raise ArgumentError,
          "accountable must be User or Staff, got #{accountable.class}" unless valid_accountable?(accountable)

    @accountable = accountable
    @type = accountable.class.name.downcase.to_sym # :user or :staff
  end

  # Factory Methods
  # ---------------

  # Find an account by ID
  #
  # @param id [String, Integer] The UUID of the user or staff
  # @param type [Symbol, String, nil] Optional type hint (:user or :staff)
  # @return [AccountService, nil] The account service or nil if not found
  def self.find(id, type: nil)
    record = find_record(id, type)
    new(record) if record
  end

  # Find an account by ID, raising an error if not found
  #
  # @param id [String, Integer] The UUID of the user or staff
  # @param type [Symbol, String, nil] Optional type hint (:user or :staff)
  # @return [AccountService] The account service
  # @raise [ActiveRecord::RecordNotFound] if not found
  def self.find!(id, type: nil)
    record = find_record(id, type)
    raise ActiveRecord::RecordNotFound, "Account not found with id: #{id}" unless record

    new(record)
  end

  # Provide ActiveRecord-style finders so callers can use keywords instead of explicit helpers.
  #
  # @param email [String, nil]
  # @param telephone [String, nil]
  # @return [AccountService, nil]
  def self.find_by(email: nil, telephone: nil)
    return nil if email.blank? && telephone.blank?

    if email.present?
      find_by_email(email)
    elsif telephone.present?
      find_by_telephone(telephone)
    end
  end

  # Find an account by email address
  #
  # @param email [String] The email address to search for
  # @return [AccountService, nil] The account service or nil if not found
  def self.find_by_email(email)
    return nil if email.blank?

    user = User.joins(:user_identity_emails).find_by(user_identity_emails: { address: email })
    staff = Staff.joins(:staff_identity_emails).find_by(staff_identity_emails: { address: email }) unless user

    accountable = user || staff
    new(accountable) if accountable
  end

  # Find an account by telephone number
  #
  # @param number [String] The telephone number to search for
  # @return [AccountService, nil] The account service or nil if not found
  def self.find_by_telephone(number)
    return nil if number.blank?

    user = User.joins(:user_identity_telephones).find_by(user_identity_telephones: { number: number })
    # Staff doesn't have phone authentication in current implementation
    new(user) if user
  end

  # Type Checking Methods
  # ---------------------

  # Check if this account represents a User
  #
  # @return [Boolean] true if this is a user account
  def user?
    type == :user
  end

  # Check if this account represents a Staff
  #
  # @return [Boolean] true if this is a staff account
  def staff?
    type == :staff
  end

  # Duck Typing Support
  # -------------------

  # Override class method to return the underlying model's class
  # This ensures JWT generation and type checks continue to lean on the wrapped model.
  #
  # @return [Class] User or Staff class
  delegate :class, to: :accountable

  # Override is_a? to check against the underlying model
  # This ensures Pundit and other type checks work correctly
  #
  # @param klass [Class] The class to check against
  # @return [Boolean] true if the underlying model is of the given type
  def is_a?(klass)
    super || accountable.is_a?(klass)
  end

  # Override kind_of? (alias for is_a?)
  alias kind_of? is_a?

  # Session Management
  # ------------------

  # Create a new session for this account
  #
  # @return [UserToken, StaffToken] The created session
  def create_session!
    case type
    when :user
      UserToken.create!(user: accountable)
    when :staff
      StaffToken.create!(staff: accountable)
    end
  end

  # Get all sessions for this account
  #
  # @return [ActiveRecord::Relation] The sessions collection
  def sessions
    case type
    when :user
      accountable.user_tokens
    when :staff
      accountable.staff_tokens
    end
  end

  # Destroy all sessions for this account
  #
  # @return [Integer] Number of sessions destroyed
  def destroy_all_sessions!
    sessions.destroy_all.size
  end

  # Identity Management
  # -------------------

  # Get all email addresses associated with this account
  #
  # @return [ActiveRecord::Relation, Array] Collection of email records
  def emails
    return accountable.emails if accountable.respond_to?(:emails)
    return accountable.user_identity_emails if accountable.respond_to?(:user_identity_emails)
    return accountable.staff_identity_emails if accountable.respond_to?(:staff_identity_emails)

    []
  end

  # Get all telephone numbers associated with this account
  # Note: Staff accounts don't have telephone authentication
  #
  # @return [ActiveRecord::Relation, Array] Collection of telephone records or empty array
  def phones
    return [] unless user?
    return accountable.phones if accountable.respond_to?(:phones)
    return accountable.user_identity_telephones if accountable.respond_to?(:user_identity_telephones)

    []
  end

  alias telephones phones

  # Get the primary email address
  #
  # @return [String, nil] The email address or nil
  def primary_email
    emails.first&.address
  end

  # Get the primary phone number
  #
  # @return [String, nil] The phone number or nil
  def primary_phone
    phones.first&.number
  end

  # Authentication Checks
  # ---------------------

  # Check if this account can authenticate using a specific method
  #
  # @param method [Symbol] The authentication method (:email, :phone, :webauthn, :oauth, :totp)
  # @return [Boolean] true if the authentication method is available
  def authenticatable_with?(method)
    case method.to_sym
    when :email
      collection_present?(emails)
    when :phone
      user? && collection_present?(phones)
    when :webauthn
      webauthn_id.present?
    when :oauth
      user? && oauth_configured?
    when :totp
      totp_configured?
    else
      false
    end
  end

  # Get all available authentication methods
  #
  # @return [Array<Symbol>] List of available authentication methods
  def available_authentication_methods
    methods = []
    methods << :email if collection_present?(emails)
    methods << :phone if user? && collection_present?(phones)
    methods << :webauthn if webauthn_id.present?
    methods << :oauth if user? && oauth_configured?
    methods << :totp if totp_configured?
    methods
  end

  # OAuth Support
  # -------------

  # Check if OAuth is configured
  #
  # @return [Boolean] true if OAuth providers are configured
  def oauth_configured?
    return false unless user?

    accountable.user_identity_social_apple.present? ||
      accountable.user_identity_social_google.present?
  end

  # TOTP Support
  # ------------

  # Check if TOTP (Time-based One-Time Password) is configured
  #
  # @return [Boolean] true if TOTP is configured
  def totp_configured?
    case type
    when :user
      return false unless accountable.respond_to?(:user_time_based_one_time_password)

      accountable.user_time_based_one_time_password.present?
    when :staff
      return false unless accountable.respond_to?(:staff_time_based_one_time_password)

      accountable.staff_time_based_one_time_password.present?
    else
      false
    end
  end

  # Model Access
  # ------------

  # Get the underlying model instance
  # Use this when you need to access type-specific methods
  #
  # @return [User, Staff] The underlying model
  def to_model
    accountable
  end

  # Get a string representation
  #
  # @return [String] Human-readable representation
  def to_s
    "#<AccountService:#{type} id=#{id}>"
  end

  # Get detailed inspection
  #
  # @return [String] Detailed string representation
  def inspect
    "#<AccountService:#{type} id=#{id} email=#{primary_email}>"
  end

  private

    # Validate that the object is a User or Staff
    #
    # @param obj [Object] The object to validate
    # @return [Boolean] true if valid
    def valid_accountable?(obj)
      obj.is_a?(User) || obj.is_a?(Staff)
    end

    # Find a record by ID and optional type
    #
    # @param id [String, Integer] The record ID
    # @param type [Symbol, String, nil] Optional type hint
    # @return [User, Staff, nil] The found record or nil
    def self.find_record(id, type)
      case type&.to_sym
      when :user
        User.find_by(id: id)
      when :staff
        Staff.find_by(id: id)
      when nil
        User.find_by(id: id) || Staff.find_by(id: id)
      else
        raise ArgumentError, "Invalid type: #{type}. Must be :user or :staff"
      end
    end

    private_class_method :find_record

    def collection_present?(collection)
      collection.respond_to?(:exists?) ? collection.exists? : collection.any?
    end
end
