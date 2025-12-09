CloudFormation {
  Description "Test"

  Parameter("One") {
    String
    Default "Test"
    MaxLength 15
  }

  Output(:One, FnBase64(Ref("One")))

  EC2_Instance(:MyInstance) {
    DisableApiTermination external_parameters.fetch(:DisableApiTermination, "false")
    InstanceType external_parameters["InstanceType"]
    ImageId "ami-12345678"
  }
}
