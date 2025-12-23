# Base exception class for application-wide custom errors
class ApplicationError < StandardError
  def initialize(i18n_key = nil, status_code = :internal_server_error, **context)
    @i18n_key = i18n_key
    @status_code = status_code
    @context = context

    if i18n_key
      message = I18n.t(i18n_key, **context)
      StandardError.instance_method(:initialize).bind_call(self, message)
    else
      StandardError.instance_method(:initialize).bind_call(self)
    end
  end

  attr_reader :i18n_key, :status_code, :context
end
