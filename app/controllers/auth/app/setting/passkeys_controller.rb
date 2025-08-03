# frozen_string_literal: true

module Auth
  module App
    module Setting
      class PasskeysController < ApplicationController
        before_action :set_abc, only: %i[ show edit update destroy ]

        # GET /abcs or /abcs.json
        def index
          @abcs = UserRecoveryCode.all
        end

        # GET /abcs/1 or /abcs/1.json
        def show
        end

        # GET /abcs/new
        def new
          @abc = UserRecoveryCode.new
        end

        # GET /abcs/1/edit
        def edit
        end

        # POST /abcs or /abcs.json
        def create
          @abc = UserRecoveryCode.new(abc_params)

          respond_to do |format|
            if @abc.save
              format.html { redirect_to @abc, notice: t("messages.abc_successfully_created") }
              format.json { render :show, status: :created, location: @abc }
            else
              format.html { render :new, status: :unprocessable_entity }
              format.json { render json: @abc.errors, status: :unprocessable_entity }
            end
          end
        end

        # PATCH/PUT /abcs/1 or /abcs/1.json
        def update
          respond_to do |format|
            if @abc.update(abc_params)
              format.html { redirect_to @abc, notice: t("messages.abc_successfully_updated") }
              format.json { render :show, status: :ok, location: @abc }
            else
              format.html { render :edit, status: :unprocessable_entity }
              format.json { render json: @abc.errors, status: :unprocessable_entity }
            end
          end
        end

        # DELETE /abcs/1 or /abcs/1.json
        def destroy
          @abc.destroy!

          respond_to do |format|
            format.html { redirect_to abcs_path, status: :see_other, notice: t("messages.abc_successfully_destroyed") }
            format.json { head :no_content }
          end
        end

        private

        # Use callbacks to share common setup or constraints between actions.
        def set_abc
          @abc = Abc.find(params.expect(:id))
        end

        # Only allow a list of trusted parameters through.
        def abc_params
          params.expect(abc: [:staff, :password_diget])
        end
      end
    end
  end
end
