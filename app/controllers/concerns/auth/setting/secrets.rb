module Auth
  module Setting
    module Secrets
      extend ActiveSupport::Concern

      included do
        before_action :authenticate_identity!
        before_action :set_secret, only: %i[show edit update destroy]
      end

      def index
        @secrets = secret_scope.order(created_at: :desc)
      end

      def show
      end

      def new
        @secret = secret_scope.new
      end

      def edit
      end

      def create
        @secret = secret_scope.new(secret_params)

        if @secret.save
          redirect_to secret_path(@secret), notice: t("messages.secret_successfully_created")
        else
          render :new, status: :unprocessable_content
        end
      end

      def update
        if @secret.update(secret_params)
          redirect_to secret_path(@secret), notice: t("messages.secret_successfully_updated")
        else
          render :edit, status: :unprocessable_content
        end
      end

      def destroy
        @secret.destroy!
        redirect_to secrets_index_path, status: :see_other,
                                        notice: t("messages.secret_successfully_destroyed")
      end

      private

        def secret_scope
          raise NotImplementedError, "#{self.class.name} must implement #secret_scope"
        end

        def authenticate_identity!
          raise NotImplementedError, "#{self.class.name} must implement #authenticate_identity!"
        end

        def secret_param_key
          raise NotImplementedError, "#{self.class.name} must implement #secret_param_key"
        end

        def secrets_index_path
          raise NotImplementedError, "#{self.class.name} must implement #secrets_index_path"
        end

        def secret_path(secret)
          raise NotImplementedError, "#{self.class.name} must implement #secret_path"
        end

        def set_secret
          @secret = secret_scope.find(params[:id])
        end

        def secret_params
          params.expect(secret_param_key => [ :name, :value ]).tap do |attrs|
            attrs.delete(:value) if attrs[:value].blank?
          end
        end
    end
  end
end
