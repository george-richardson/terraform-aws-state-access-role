variables {
  role_name = "full-bucket-list-test"
}

run "harness" {
  module {
    source = "./tests/harness"
  }
}

run "system_under_test" {
  variables {
    name                   = var.role_name
    allow_full_bucket_list = true
    trust_policy           = run.harness.trust_policy
    state_bucket_arn       = run.harness.state_bucket_arn
    lock_table_arn         = run.harness.lock_table_arn

    can_apply = [{
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

run "can_list_other_workspaces_state_files" {
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
        values = ["another-prefix/"]
      }
    ]
  }

  assert {
    condition     = output.test_results.all_allowed
    error_message = "Cannot list workspace files under 'another-prefix/'."
  }
}