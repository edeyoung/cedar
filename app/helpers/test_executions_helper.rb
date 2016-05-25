# Minor ruby helpers for all test execution things
module TestExecutionsHelper
  def confirm_delete
    {
      confirm: 'Are you sure?',
      :'confirm-button-text' => 'Yes, delete this test',
      :'cancel-button-text' => 'No thanks',
      :'confirm-button-color' => '#da534b',
      :'sweet-alert-type' => 'warning'
    }
  end
end
