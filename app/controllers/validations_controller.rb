# Validations are what Cedar is all about
class ValidationsController < ApplicationController
  respond_to :html

  def index
    @validations = Validation.all
    respond_with(@validations)
  end

  def add_tag
    val = Validation.find(params[:id])
    val.add_tag(params[:tag])
  end

  def remove_tag
    val = Validation.find(params[:id])
    val.remove_tag(params[:tag])
  end
end
