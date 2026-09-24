.PHONY: fmt fmt-check validate test version

LABS := \
	labs/01-hello-workflow \
	labs/02-providers \
	labs/03-configuration \
	labs/04-modules \
	labs/05-state \
	labs/06-hcp-terraform \
	labs/07-vpc \
	labs/08-eks-platform \
	backend/bootstrap

version:
	@terraform version | grep -E 'Terraform v1\.12\.' >/dev/null || { \
		echo "Terraform 1.12.x is required. From the repo root: tfenv install && tfenv use"; \
		exit 1; \
	}

fmt:
	terraform fmt -recursive

fmt-check: version
	terraform fmt -recursive -check

validate: version fmt-check
	@set -e; \
	for dir in $(LABS); do \
		echo "==> $$dir"; \
		terraform -chdir="$$dir" init -backend=false -input=false; \
		terraform -chdir="$$dir" validate; \
	done
	terraform -chdir=modules/naming init -backend=false -input=false
	terraform -chdir=modules/naming test

test: validate
