# Measures are what Cedar is all about
class MeasuresController < ApplicationController
  respond_to :html

  def index
    @measures = Measure.all.top_level.only(:_id, :bundle_id, :name, :cms_id, :description, :type, :continuous_variable, :tags).sort_by(&:cms_id)
    respond_with(@measures)
  end

  def add_tag
    val = Measure.find_by _id: params[:id]
    val.add_tag(params[:tag])
  end

  def remove_tag
    val = Measure.find_by _id: params[:id]
    val.remove_tag(params[:tag])
  end
end
