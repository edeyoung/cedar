# While the steps controller takes care of the wizard, this should take care of
# basic test execution creation items
class TestExecutionsController < ApplicationController
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
    @test_executions = TestExecution.all.user(current_user)
    @tests_incomplete = @test_executions.state(:incomplete)
    @tests_passed = @test_executions.state(:passed)
    @tests_failed = @test_executions.state(:failed)
    dashboard_errors
    @prevent_test = !(bundle_exists? && validation_exists?)
  end

  private

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
