run "dev_prefix" {
  command = plan

  variables {
    prefix      = "tf004"
    environment = "dev"
    extra_tags = {
      Owner = "learner"
    }
  }

  assert {
    condition     = output.name_prefix == "tf004-dev"
    error_message = "name_prefix should join prefix and environment."
  }

  assert {
    condition     = output.tags["Environment"] == "dev" && output.tags["Owner"] == "learner"
    error_message = "extra_tags should merge over the default tag map."
  }
}

run "rejects_uppercase_prefix" {
  command = plan

  variables {
    prefix      = "TF004"
    environment = "dev"
  }

  expect_failures = [
    var.prefix,
  ]
}
