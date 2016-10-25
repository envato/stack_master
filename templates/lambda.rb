SparkleFormation.new(:lambda) do
  description "Test Lambda Function"

  dynamic!(
    :lambda_function,
    "ec_snapshot_creator",
    description: "Create ElastiCache snapshots for instances",
    memorysize: "128",
    role: ref!(:role),
    handler: "index.lambda_handler",
    runtime: "python2.7",
    timeout: 2,
    code: lambda_code!("ec-snapshot-cleaner.py")
  )

end
