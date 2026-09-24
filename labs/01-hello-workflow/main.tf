# Domain 1 — Infrastructure as code.
# You describe the desired result in this file. Terraform builds a graph,
# plans a diff against state, and applies only that diff. The same workflow
# targets AWS, another cloud, or no cloud at all. This lab uses the random
# provider so Day 1 has no AWS account and no bill.
#
# Domain 3 — init, fmt, validate, plan, apply, destroy. Commands are in README.md.

resource "random_pet" "learner" {
  prefix = var.learner
  length = 2
}

resource "terraform_data" "hello" {
  input = {
    message = var.message
    pet     = random_pet.learner.id
  }
}
