#!/bin/bash

export REPO_NAME="alphagov/govuk-content-schemas"
export CONTEXT_MESSAGE="Verify govuk_schemas_gem against content schemas"

exec ./jenkins.sh
