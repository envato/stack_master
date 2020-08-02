# Patching Example

In this example, two separate, nearly identical stacks have been merged into one.

- `AWS::ECR::Repository` resources are replaced if the `LogicalName` in the stack changes.
- This results in CloudFormation proposing a replacement: deleting the existing ECR, then creating a new one.

The common logic for the ECR resources could be extracted into a SparkleFormation template, but this involves a significant change in order to rename two keys. This example uses [JSON Patches](http://jsonpatch.com/) ([RFC6902](https://tools.ietf.org/html/rfc6902)) instead, avoiding the need to convert the base template.
