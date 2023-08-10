resource "remote" "setup" {
  command = [""]
}

resource "run_solve" "run_installation" {
  task = blah.task.id
}

local "homepage_selector" {
  value = resource.chapter.thing.output == "blah" ? "a" : "b"
}

resource "navigate_to" "home_page" {
  url      = "http://something"
  selector = local.homepage_selector
}

resource "check_script" "installation" {
  id = bla.task.id
}

scenario "Test installation setup" {
  // load the module from the parent folder
  source = "../"

  test {
    context "the docs are loaded on on the home page" {
      before = [
        resource.navigate_to.home_page
      ]
    }

    it "runs the check script" {
      expect = resource.check_script.installation.response == false
    }

    it "runs the solve script" {
      expect = resource.check_script.installation.response == true
    }

    it "runs the check script" {
      expect = resource.check_script.installation.response == true
    }
  }

}