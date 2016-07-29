# While the steps controller takes care of the wizard, this should take care of
# basic test execution creation items
class TestExecutionsController < ApplicationController
  respond_to :html, :js

  def new
    redirect_to test_execution_step_path(TestExecution.create(user_id: current_user.id), id: :details)
  end

  def show
    redirect_to test_execution_step_path(@test_execution)
  end

  def qrda_progress
    te = TestExecution.find(params[:id])
    render json: { qrda_progress: te[:qrda_progress], file_path: te[:file_path] } if request.xhr?
  end

  def destroy
    TestExecution.find(params[:id]).destroy
    flash[:success] = 'Test deleted!'
    redirect_to root_url
  end

  def copy
    redirect_to test_execution_step_path(TestExecution.find(params[:id]).dup_test, id: :details)
  end

  def dashboard
    @test_executions = TestExecution.all.user(current_user).order_by_date
    set_vars
    dashboard_errors
  end

  def with_time_range
    @test_executions = TestExecution.all.user(current_user).where(created_at: (Time.at(params[:start].to_i).utc..Time.at(params[:end].to_i).utc))
    set_vars
    respond_to do |format|
      format.js
    end
  end

  private

  def set_vars
    @tests_incomplete = @test_executions.state(:incomplete)
    @tests_passed = @test_executions.state(:passed)
    @tests_failed = @test_executions.state(:failed)
    @tests_complete = @tests_passed | @tests_failed
    @prevent_test = !bundle_exists?
    @validations = Validation.all.to_a
    @validations << Validation.new(name: 'Accept Valid Files', code: :valid)
  end

  def bundle_exists?
    HealthDataStandards::CQM::Bundle.first
    true
  rescue
    false
  end

  def dashboard_errors
    unless bundle_exists?
      flash[:error] = 'Please make sure at least one bundle is uploaded before you run Cedar. See the bundle installation instructions in the README'
    end
  end
end
