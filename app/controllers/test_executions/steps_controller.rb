# Steps for creation of test executions are implemented c/o the wicked gem
class TestExecutions::StepsController < ApplicationController
  include Wicked::Wizard
  steps :details, :measures, :validations, :download, :enter_results, :overview

  def show
    @test_execution = TestExecution.find(params[:test_execution_id])
    update_position
    case step
    when :measures
      @measures = Measure.all.bundle_id(@test_execution.bundle.id).top_level.only(:_id, :name, :cms_id, :title, :tags).sort_by(&:cms_id)
      @all_tags = get_all_tags(@measures)
    when :validations
      @useful_validations = @test_execution.determine_useful_validations
      @all_tags = get_all_tags(@useful_validations)
    when :download
      # @test_execution.create_documents # Only for debug
      CreateDocumentsJob.perform_later(@test_execution)
    when :overview
      @test_execution.set_overview_state
    end
    render_wizard
  end

  def update
    @test_execution = TestExecution.find(params[:test_execution_id])
    @test_execution.update_attributes(test_execution_params)
    render_wizard @test_execution
  end

  private

  def test_execution_params
    params.require(:test_execution).permit(
      :user_id,
      :name,
      :description,
      :reporting_period,
      :qrda_type,
      :results,
      measure_ids: [],
      validation_ids: [],
      documents_attributes: [:id, :name, :actual_result, :test_index]
    )
  end

  def get_all_tags(things)
    all_tags = []
    things.each { |thing| all_tags += thing.tags }
    all_tags.uniq
  end

  def update_position
    @test_execution.update_attribute(:step, step)
    @current_step_number = current_step_index + 1
    @total_steps = steps.count
    # If we're still in the wizard, update progress for the dashboard
    if current_step_index
      @test_execution.update_attribute(
        :wizard_progress, (current_step_index + 1) * (100 / steps.count)
      )
    # Otherwise, we can pass/fail the test based on the document results
    else
      @test_execution.update_attribute(:progress, 100)
    end
  end
end
