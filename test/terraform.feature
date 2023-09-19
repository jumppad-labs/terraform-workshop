Feature: Test Documentation
  In order to test the Terraform workfbook 
  I should apply a blueprint which defines a simple setup
  and test the resources are created correctly

Scenario: Start docs
  Given I have a running blueprint
  Then the following resources should be running
    | name                                     |
    | resource.container.vscode                |
    | resource.docs.docs                       |
  And a HTTP call to "http://localhos/" should result in status 200
  And a HTTP call to "http://localhost:8000/" should result in status 302