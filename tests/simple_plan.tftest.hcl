variables {
  role_name = "simple-plan-test"
}

run "harness" {
  module {
    source = "./tests/harness"
  }
}

run "system_under_test" {
  variables {
    name             = var.role_name
    trust_policy     = run.harness.trust_policy
    state_bucket_arn = run.harness.state_bucket_arn
    lock_table_arn   = run.harness.lock_table_arn

    can_plan = [{
      key = "terraform.tfstate"
    }]
  }
}

run "can_list_workspaces_state_files" {
  module {
    source = "./tests/policy_simulation"
  }

  variables {
    action_names      = ["s3:ListBucket"] # Actually ListObjectsV2 under the hood
    policy_source_arn = run.system_under_test.role_arn
    resource_arns     = [run.harness.state_bucket_arn]
    contexts = [
      {
        key    = "s3:prefix"
        type   = "string"
        values = ["env:/"]
      }
    ]
  }

  assert {
    condition     = output.test_results.all_allowed
    error_message = "Cannot list workspace files under 'env:/'."
  }
}

run "cannot_list_other_workspaces_state_files" {
  module {
    source = "./tests/policy_simulation"
  }

  variables {
    action_names      = ["s3:ListBucket"] # Actually ListObjectsV2 under the hood
    policy_source_arn = run.system_under_test.role_arn
    resource_arns     = [run.harness.state_bucket_arn]
    contexts = [
      {
        key    = "s3:prefix"
        type   = "string"
        values = ["not-listable/"]
      }
    ]
  }

  assert {
    condition     = !output.test_results.all_allowed
    error_message = "Can list workspace files under 'not-listable/'."
  }
}

run "can_read_default_workspace_state_file" {
  module {
    source = "./tests/policy_simulation"
  }

  variables {
    action_names      = ["s3:GetObject"]
    policy_source_arn = run.system_under_test.role_arn
    resource_arns     = ["${run.harness.state_bucket_arn}/terraform.tfstate"]
  }

  assert {
    condition     = output.test_results.all_allowed
    error_message = "Cannot read default workspace state file."
  }
}

run "cannot_read_other_workspace_state_file" {
  module {
    source = "./tests/policy_simulation"
  }

  variables {
    action_names      = ["s3:GetObject"]
    policy_source_arn = run.system_under_test.role_arn
    resource_arns     = ["${run.harness.state_bucket_arn}/not-readable.tfstate"]
  }

  assert {
    condition     = !output.test_results.all_allowed
    error_message = "Can read 'not-readable.tfstate'."
  }
}

run "cannot_write_default_workspace_state_file" {
  module {
    source = "./tests/policy_simulation"
  }

  variables {
    action_names      = ["s3:PutObject"]
    policy_source_arn = run.system_under_test.role_arn
    resource_arns     = ["${run.harness.state_bucket_arn}/terraform.tfstate"]
  }

  assert {
    condition     = !output.test_results.all_allowed
    error_message = "Can write default workspace state file."
  }
}

run "cannot_write_other_workspace_state_file" {
  module {
    source = "./tests/policy_simulation"
  }

  variables {
    action_names      = ["s3:PutObject"]
    policy_source_arn = run.system_under_test.role_arn
    resource_arns     = ["${run.harness.state_bucket_arn}/not-writable.tfstate"]
  }

  assert {
    condition     = !output.test_results.all_allowed
    error_message = "Can write 'not-writable.tfstate'."
  }
}

run "can_read_default_workspace_lock" {
  module {
    source = "./tests/policy_simulation"
  }

  variables {
    action_names      = ["dynamodb:GetItem"]
    policy_source_arn = run.system_under_test.role_arn
    resource_arns     = [run.harness.lock_table_arn]
    contexts = [
      {
        key    = "dynamodb:LeadingKeys"
        type   = "stringList"
        values = ["${run.harness.state_bucket_name}/terraform.tfstate"]
      }
    ]
  }

  assert {
    condition     = output.test_results.all_allowed
    error_message = "Cannot read lock for default workspace."
  }
}

run "cannot_read_other_workspace_lock" {
  module {
    source = "./tests/policy_simulation"
  }

  variables {
    action_names      = ["dynamodb:GetItem"]
    policy_source_arn = run.system_under_test.role_arn
    resource_arns     = [run.harness.lock_table_arn]
    contexts = [
      {
        key    = "dynamodb:LeadingKeys"
        type   = "stringList"
        values = ["${run.harness.state_bucket_name}/not-readable.tfstate"]
      }
    ]
  }

  assert {
    condition     = !output.test_results.all_allowed
    error_message = "Can read lock for 'not-readable.tfstate'."
  }
}

run "can_read_default_workspace_lock_hash" {
  module {
    source = "./tests/policy_simulation"
  }

  variables {
    action_names      = ["dynamodb:GetItem"]
    policy_source_arn = run.system_under_test.role_arn
    resource_arns     = [run.harness.lock_table_arn]
    contexts = [
      {
        key    = "dynamodb:LeadingKeys"
        type   = "stringList"
        values = ["${run.harness.state_bucket_name}/terraform.tfstate-md5"]
      }
    ]
  }

  assert {
    condition     = output.test_results.all_allowed
    error_message = "Cannot read lock hash for default workspace."
  }
}

run "cannot_read_other_workspace_lock_hash" {
  module {
    source = "./tests/policy_simulation"
  }

  variables {
    action_names      = ["dynamodb:GetItem"]
    policy_source_arn = run.system_under_test.role_arn
    resource_arns     = [run.harness.lock_table_arn]
    contexts = [
      {
        key    = "dynamodb:LeadingKeys"
        type   = "stringList"
        values = ["${run.harness.state_bucket_name}/not-readable.tfstate-md5"]
      }
    ]
  }

  assert {
    condition     = !output.test_results.all_allowed
    error_message = "Can read lock hash for 'not-readable.tfstate'."
  }
}

run "can_write_default_workspace_lock" {
  module {
    source = "./tests/policy_simulation"
  }

  variables {
    action_names      = ["dynamodb:PutItem"]
    policy_source_arn = run.system_under_test.role_arn
    resource_arns     = [run.harness.lock_table_arn]
    contexts = [
      {
        key    = "dynamodb:LeadingKeys"
        type   = "stringList"
        values = ["${run.harness.state_bucket_name}/terraform.tfstate"]
      }
    ]
  }

  assert {
    condition     = output.test_results.all_allowed
    error_message = "Cannot write lock for default workspace."
  }
}

run "cannot_write_other_workspace_lock" {
  module {
    source = "./tests/policy_simulation"
  }

  variables {
    action_names      = ["dynamodb:PutItem"]
    policy_source_arn = run.system_under_test.role_arn
    resource_arns     = [run.harness.lock_table_arn]
    contexts = [
      {
        key    = "dynamodb:LeadingKeys"
        type   = "stringList"
        values = ["${run.harness.state_bucket_name}/not-writeable.tfstate"]
      }
    ]
  }

  assert {
    condition     = !output.test_results.all_allowed
    error_message = "Can write lock for 'not-writeable.tfstate'."
  }
}

run "can_write_default_workspace_lock_hash" {
  module {
    source = "./tests/policy_simulation"
  }

  variables {
    action_names      = ["dynamodb:PutItem"]
    policy_source_arn = run.system_under_test.role_arn
    resource_arns     = [run.harness.lock_table_arn]
    contexts = [
      {
        key    = "dynamodb:LeadingKeys"
        type   = "stringList"
        values = ["${run.harness.state_bucket_name}/terraform.tfstate-md5"]
      }
    ]
  }

  assert {
    condition     = output.test_results.all_allowed
    error_message = "Cannot write lock hash for default workspace."
  }
}

run "cannot_write_other_workspace_lock_hash" {
  module {
    source = "./tests/policy_simulation"
  }

  variables {
    action_names      = ["dynamodb:PutItem"]
    policy_source_arn = run.system_under_test.role_arn
    resource_arns     = [run.harness.lock_table_arn]
    contexts = [
      {
        key    = "dynamodb:LeadingKeys"
        type   = "stringList"
        values = ["${run.harness.state_bucket_name}/not-writeable.tfstate-md5"]
      }
    ]
  }

  assert {
    condition     = !output.test_results.all_allowed
    error_message = "Can write lock hash for 'not-writeable.tfstate'."
  }
}