# Validations are what Cedar is all about
class ValidationsController < ApplicationController
  before_action :set_validation, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @validations = Validation.all
    respond_with(@validations)
  end

  def show
    respond_with(@validation)
  end

  def new
    @validation = Validation.new
    respond_with(@validation)
  end

  def edit
  end

  def create
    @validation = Validation.new(validation_params)
    @validation.save
    respond_with(@validation)
  end

  def update
    @validation.update(validation_params)
    respond_with(@validation)
  end

  def destroy
    @validation.destroy
    respond_with(@validation)
  end

  private

  def set_validation
    @validation = Validation.find(params[:id])
  end

  def validation_params
    params.require(:validation).permit(
      :name, :code, :description, :overview_text, :qrda_type
    )
  end
end
