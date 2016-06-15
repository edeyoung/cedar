# Steps for creation of test executions are implemented c/o the wicked gem
class TestExecutions::StepsController < ApplicationController
  include Wicked::Wizard
  steps :details, :measures, :validations, :download, :enter_results, :overview

  def show
    @test_execution = TestExecution.find(params[:test_execution_id])
    update_position
    case step
    when :measures
      @measures = Measure.where(bundle_id: @test_execution.bundle.id).top_level.only(:_id, :name, :cms_id, :title, :tags).sort_by(&:cms_id)
      @all_tags = get_all_tags(@measures)
    when :validations
      @useful_validations = determine_useful_validations
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

  # Take the intersection of all checks for useful validations given test conditions
  def determine_useful_validations
    useful_checks = [
      useful_validations_for_qrda_type,
      useful_validations_for_measure_type
    ]
    useful_checks.inject(:&)
  end

  def useful_validations_for_qrda_type
    Validation.all.qrda_type(@test_execution.qrda_type) + Validation.all.qrda_type('all')
  end

  # If both continuous and discrete measures are selected, validations for both types of measure are valid
  # If only one type is selected, remove the validations specific to the other type
  def useful_validations_for_measure_type
    selected_measure_types = { discrete: false, continuous: false }
    @test_execution.measure_ids.each do |measure_id|
      measure = HealthDataStandards::CQM::Measure.find_by(_id: measure_id)
      measure.continuous_variable ? selected_measure_types[:continuous] = true : selected_measure_types[:discrete] = true
    end
    if selected_measure_types[:discrete] == false
      Validation.all - Validation.all.measure_type('discrete')
    elsif selected_measure_types[:continuous] == false
      Validation.all - Validation.all.measure_type('continuous')
    else
      Validation.all.to_a
    end
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
