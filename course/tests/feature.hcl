variable "context" {
  default = {
    selector = ".search-box"
  }
}

local "context" {
  selector = resource.chapter.thing.output == "blah" ? "a" : "b" 
}

feature "Test installation setup" {
  description = <<-EOF
    In order to test Shipyard can build images
    I should apply a blueprint which defines a simple container setup
    and test the resources are created correctly
  EOF

  scenario {
    description = <<-EOF
      Scenario: "Test the Welcome page"
      Given the a browser page "${resource.chapter.installation.page.manual_installation.fqdn}" is loaded
      Then I wait for the selector "${variable.context.selector}"
        And I wait for the text "${resource.chapter.installation.page.manual_installation.content}"
      When I run the check script for the task "resources.task.manual_installation"
        And I run the solve script for the task "resources.task.manual_installation"
        And I run the check script "resources.task.manual_installation"
        And I click the button ".next_button"
      Then I expect the text "First task"
    EOF
  }

  scenario {     
    description= <<-EOF
      Scenario: "Test the Welcome page"
      Given the a browser page "https://blah.com/installation.mdx" is loaded
        And I wait for the selector ".search-box"
        And I wait for the text "Welcome to something"
      Then I run the check script for the task "resources.task.manual_installation"
      Then I run the solve script for the task "resources.task.manual_installation"
      Then I run the check script "resources.task.manual_installation"
      Then I click the button ".next_button"
      And I wait for the text "First task"
    EOF
  }
    
  scenario {
    description = template_file("blah.feature", {a="b"})
  }

  scenario {
    description = file("blah.feature")
  }
}