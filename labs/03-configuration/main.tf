resource "terraform_data" "topic" {
  for_each = var.topics

  input = {
    name   = each.key
    domain = each.value.domain
    notes  = each.value.notes
  }
}

resource "terraform_data" "base" {
  input = "base"
}

resource "terraform_data" "dependent" {
  input = terraform_data.base.output

  # depends_on is for relationships Terraform cannot see from references.
  # The input reference above already creates an edge; depends_on is here
  # so objective 4f is visible in the lab.
  depends_on = [terraform_data.base]

  lifecycle {
    create_before_destroy = true

    precondition {
      condition     = terraform_data.base.output == "base"
      error_message = "terraform_data.base must record the string base before the dependent resource is created."
    }
  }
}

resource "terraform_data" "token_length" {
  # nonsensitive() is deliberate: the length is not the secret.
  # The token itself is a sensitive output and is redacted in the CLI.
  input = nonsensitive(length(var.example_api_token))
}

check "domains_in_range" {
  assert {
    condition     = alltrue([for topic in values(var.topics) : topic.domain >= 1 && topic.domain <= 8])
    error_message = "Every topic domain must be an Associate exam domain from 1 to 8."
  }
}

check "token_is_not_empty" {
  assert {
    condition     = length(var.example_api_token) > 0
    error_message = "example_api_token is empty."
  }
}
