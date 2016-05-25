# Creates links for all the wizard steps
module TestExecutions::StepsHelper
  def progress_bar
    content_tag(:section, class: 'content') do
      content_tag(:div, class: 'navigation progress-wizard') do
        content_tag(:div, class: 'container') do
          content_tag(:ol) do
            wizard_steps.collect do |every_step|
              class_str = 'unfinished'
              class_str = 'current'  if every_step == step
              class_str = 'finished' if past_step?(every_step)
              concat(
                content_tag(:li, class: class_str) do
                  # Some text manipulation here to turn the symbol into a title
                  link_to every_step.to_s.gsub(/[_]/, ' ').titleize, wizard_path(every_step)
                end
              )
            end
          end
        end
      end
    end
  end
end
