# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

# config/initializers/content_security_policy.rb
Rails.application.config.content_security_policy do |policy|
  policy.default_src :self, :https
  policy.font_src    :self, :https, :data
  policy.img_src     :self, :https, :data
  policy.object_src  :none
  policy.script_src  :self, :https
  policy.style_src   :self, :https
end

# Enable automatic nonce generation with the following configuration when using nonces.
# If you are using UJS then enable automatic nonce generation
Rails.application.config.content_security_policy_nonce_generator = ->(request) { SecureRandom.base64(16) }

# You can enable nonce attributes for specific directives (such as script or img).
# Example: script-src 'nonce-XXX', img-src 'nonce-YYY'.
# Set the nonce only to specific directives
Rails.application.config.content_security_policy_nonce_directives = %w[script-src]
