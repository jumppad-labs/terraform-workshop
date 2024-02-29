test "browser" "welcome" {
  page = "http://docs.container.jumppad.run/docs/installation/manual_installation.mdx"

  viewport {
    width  = 1280
    height = 1024
  }

  wait {
    selector = ".seach-box"
  }

  wait {
    text = "Welcome to some stuff"
  }

  click {
    selector = ".next_button"
  }

  wait {
    text = "First task installing"
  }
}

test "docs_check" "installation" {
  task = resource.task.manual_installationmeta.id

  pass = false
}

test "docs_solve" "installation" {
  task = resource.task.manual_installationmeta.id
}

test "docs_check" "installation" {
  task = resource.task.manual_installationmeta.id

  pass = true
}

test "browser" "installation" {
  page = "http://docs.container.jumppad.run/docs/installation/manual_installation.mdx"

  viewport {
    width  = 1280
    height = 1024
  }

  wait {
    selector = ".seach-box"
  }

  click {
    selector = ".next_button"
  }
}

scenario "Welcome Page" {
  when i navigate to " " http : //blah.com" {
  viewport {
    height = 1024
    width  = 768
  }
}

then "i wait for the selector" { value = variable.selector_next_button }
and "i wait for the text" { value = "Welcome to " }

then i_run_the_check_script = resources.task.manual_installationmeta.id
and i_run_the_solve_script  = resources.task.manual_installationmeta.id
and i_run_the_check_script  = resources.task.manual_installationmeta.id

then i_click_button = variable.selector_next_button
and i_wait_for_text = "Welcome to "
}

feature "Test the first part of the thing" {
  configure {
    load {
      viewport {
        width  = 1280
        height = 1024
      }
    }
  }
}

scenario "Welcome Page" {
  step "load" "http://docs.container.jumppad.run/docs/installation/manual_installation.mdx" {
  }

  check "the intro text is displayed" {}

  click variable.next_button {}

  execute "the check script to ensure fails" {}

  execute "the solve script to complete the task" {}

  execute "the check script to ensure pass" {}

  click variable.next_button
}

# Load the main page
# Check that the intro text is displayed
# Click next to show first exercise
# Run the check script to ensure fails
# Run the solve script to complete the task
# Run the check script to ensure pass
# Click next