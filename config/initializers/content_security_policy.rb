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

# nonceを利用する場合、以下の設定をすることで nonce の自動生成を有効にできます。
# If you are using UJS then enable automatic nonce generation
Rails.application.config.content_security_policy_nonce_generator = ->(request) { SecureRandom.base64(16) }

# 特定のディレクティブ(sciprtとかimg)に対して、nonce属性を有効にすることができます。
# script-src: 'nonce-XXX' img-src: 'nonce-YYY' とかってできる
# Set the nonce only to specific directives
Rails.application.config.content_security_policy_nonce_directives = %w[script-src]
