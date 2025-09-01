module Apex
  module Org
    class CustomersController < ApplicationController
      before_action :set_customer, only: [ :show, :edit, :update, :destroy ]

      def index
        @customers = [
          { id: 1, name: "Acme Corp", email: "contact@acme.com", status: "active" },
          { id: 2, name: "Beta Inc", email: "info@beta.com", status: "inactive" },
          { id: 3, name: "Gamma LLC", email: "hello@gamma.com", status: "active" }
        ]
      end

      def show
        @customer_details = {
          subscription: "Enterprise",
          last_login: 2.days.ago,
          total_users: 50
        }
      end

      def new
        @customer = { name: "", email: "", status: "active" }
      end

      def edit
      end

      def create
        customer_params = params.permit(:name, :email, :status)

        if customer_params[:name].present? && customer_params[:email].present?
          flash[:notice] = I18n.t("apex.org.customers.created", name: customer_params[:name])
          redirect_to apex_org_customers_path
        else
          flash[:alert] = I18n.t("apex.org.customers.name_email_required")
          render :new, status: :unprocessable_content
        end
      end

      def update
        customer_params = params.permit(:name, :email, :status)

        if customer_params.present?
          flash[:notice] = I18n.t("apex.org.customers.updated")
          redirect_to apex_org_customer_path(@customer[:id])
        else
          flash[:alert] = I18n.t("apex.org.customers.invalid_data")
          render :edit, status: :unprocessable_content
        end
      end

      def destroy
        flash[:notice] = I18n.t("apex.org.customers.deleted", name: @customer[:name])
        redirect_to apex_org_customers_path
      end

      private

      def set_customer
        customer_id = params[:id].to_i
        @customer = {
                      1 => { id: 1, name: "Acme Corp", email: "contact@acme.com", status: "active" },
                      2 => { id: 2, name: "Beta Inc", email: "info@beta.com", status: "inactive" },
                      3 => { id: 3, name: "Gamma LLC", email: "hello@gamma.com", status: "active" }
                    }[customer_id] || { id: customer_id, name: "Unknown", email: "", status: "unknown" }
      end
    end
  end
end
