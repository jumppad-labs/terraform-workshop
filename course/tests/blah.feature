Scenario: "Test the Welcome page"
  Given the a browser page "${resource.chapter.installation.page.manual_installation.fqdn}" is loaded
Then I wait for the selector "${variable.context.selector}"
  And I wait for the text "${resource.chapter.installation.page.manual_installation.content}"
When I run the check script for the task "resources.task.manual_installation"
  And I run the solve script for the task "resources.task.manual_installation"
  And I run the check script "resources.task.manual_installation"
  And I click the button ".next_button"
Then I expect the text "${vars.a}"