variables {
  role_name = "advanced-read-test"
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

    can_read = [{
      key                     = "terraform.tfstate"
      workspace_key_prefix    = "prefix"
      workspaces              = ["can"]
      allow_default_workspace = false
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
        values = ["prefix/"]
      }
    ]
  }

  assert {
    condition     = output.test_results.all_allowed
    error_message = "Cannot list workspace files under 'prefix/'."
  }
}

run "cannot_read_default_workspace_state_file" {
  module {
    source = "./tests/policy_simulation"
  }

  variables {
    action_names      = ["s3:GetObject"]
    policy_source_arn = run.system_under_test.role_arn
    resource_arns     = ["${run.harness.state_bucket_arn}/terraform.tfstate"]
  }

  assert {
    condition     = !output.test_results.all_allowed
    error_message = "Can read default workspace state file."
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

run "can_read_configured_workspace_state_file" {
  module {
    source = "./tests/policy_simulation"
  }

  variables {
    action_names      = ["s3:GetObject"]
    policy_source_arn = run.system_under_test.role_arn
    resource_arns     = ["${run.harness.state_bucket_arn}/prefix/can/terraform.tfstate"]
  }

  assert {
    condition     = output.test_results.all_allowed
    error_message = "Cannot read configured workspace state file."
  }
}

run "cannot_write_configured_workspace_state_file" {
  module {
    source = "./tests/policy_simulation"
  }

  variables {
    action_names      = ["s3:PutObject"]
    policy_source_arn = run.system_under_test.role_arn
    resource_arns     = ["${run.harness.state_bucket_arn}/prefix/can/terraform.tfstate"]
  }

  assert {
    condition     = !output.test_results.all_allowed
    error_message = "Can write configured workspace state file."
  }
}

run "cannot_read_not_configured_workspace_state_file" {
  module {
    source = "./tests/policy_simulation"
  }

  variables {
    action_names      = ["s3:GetObject"]
    policy_source_arn = run.system_under_test.role_arn
    resource_arns     = ["${run.harness.state_bucket_arn}/prefix/cannot/terraform.tfstate"]
  }

  assert {
    condition     = !output.test_results.all_allowed
    error_message = "Can read not configured workspace state file."
  }
}

run "cannot_write_not_configured_workspace_state_file" {
  module {
    source = "./tests/policy_simulation"
  }

  variables {
    action_names      = ["s3:PutObject"]
    policy_source_arn = run.system_under_test.role_arn
    resource_arns     = ["${run.harness.state_bucket_arn}/prefix/cannot/terraform.tfstate"]
  }

  assert {
    condition     = !output.test_results.all_allowed
    error_message = "Can write not configured workspace state file."
  }
}

run "cannot_read_default_workspace_lock" {
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
    condition     = !output.test_results.all_allowed
    error_message = "Can read lock for default workspace."
  }
}

run "cannot_read_default_workspace_lock_hash" {
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
    condition     = !output.test_results.all_allowed
    error_message = "Can read lock hash for default workspace."
  }
}

run "cannot_write_default_workspace_lock" {
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
    condition     = !output.test_results.all_allowed
    error_message = "Can write lock for default workspace."
  }
}

run "cannot_write_default_workspace_lock_hash" {
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
    condition     = !output.test_results.all_allowed
    error_message = "Can write lock hash for default workspace."
  }
}

run "cannot_read_configured_workspace_lock" {
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
        values = ["${run.harness.state_bucket_name}/prefix/can/terraform.tfstate"]
      }
    ]
  }

  assert {
    condition     = !output.test_results.all_allowed
    error_message = "Can read lock for configured workspace."
  }
}

run "cannot_read_configured_workspace_lock_hash" {
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
        values = ["${run.harness.state_bucket_name}/prefix/can/terraform.tfstate-md5"]
      }
    ]
  }

  assert {
    condition     = !output.test_results.all_allowed
    error_message = "Can read lock hash for configured workspace."
  }
}

run "cannot_write_configured_workspace_lock" {
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
        values = ["${run.harness.state_bucket_name}/prefix/can/terraform.tfstate"]
      }
    ]
  }

  assert {
    condition     = !output.test_results.all_allowed
    error_message = "Can write lock for configured workspace."
  }
}

run "cannot_write_configured_workspace_lock_hash" {
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
        values = ["${run.harness.state_bucket_name}/prefix/can/terraform.tfstate-md5"]
      }
    ]
  }

  assert {
    condition     = !output.test_results.all_allowed
    error_message = "Can write lock hash for configured workspace."
  }
}

run "cannot_read_not_configured_workspace_lock" {
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
        values = ["${run.harness.state_bucket_name}/prefix/cannot/terraform.tfstate"]
      }
    ]
  }

  assert {
    condition     = !output.test_results.all_allowed
    error_message = "Can read lock for not configured workspace."
  }
}

run "cannot_read_not_configured_workspace_lock_hash" {
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
        values = ["${run.harness.state_bucket_name}/prefix/cannot/terraform.tfstate-md5"]
      }
    ]
  }

  assert {
    condition     = !output.test_results.all_allowed
    error_message = "Can read lock hash for not configured workspace."
  }
}

run "cannot_write_not_configured_workspace_lock" {
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
        values = ["${run.harness.state_bucket_name}/prefix/cannot/terraform.tfstate"]
      }
    ]
  }

  assert {
    condition     = !output.test_results.all_allowed
    error_message = "Can write lock for not configured workspace."
  }
}

run "cannot_write_not_configured_workspace_lock_hash" {
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
        values = ["${run.harness.state_bucket_name}/prefix/cannot/terraform.tfstate-md5"]
      }
    ]
  }

  assert {
    condition     = !output.test_results.all_allowed
    error_message = "Can write lock hash for not configured workspace."
  }
}