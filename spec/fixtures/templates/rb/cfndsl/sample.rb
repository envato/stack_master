CloudFormation do
  Description "Test"

  Parameter("One") do
    String
    Default "Test"
    MaxLength 15
  end

  Output(:One, FnBase64(Ref("One")))

  EC2_Instance(:MyInstance) do
    ImageId "ami-12345678"
  end
end
