![StackMaster](/logo.png?raw=true)

StackMaster is a CLI tool to manage CloudFormation stacks, with the following features:

- Synchronous visibility into stack updates. See exactly what is changing and
  what will happen before agreeing to apply a change.
- Dynamic parameter resolvers.
- Template compiler support for YAML and [SparkleFormation](http://www.sparkleformation.io).

Stack updates can cause a lot of damage if applied blindly. StackMaster helps
with this by providing the operator with as much information about the proposed
change as possible before asking for confirmation to continue. That information
includes:

- Template body and parameter diffs.
- [Change
  sets](https://aws.amazon.com/blogs/aws/new-change-sets-for-aws-cloudformation/)
are displayed for review.
- Once the diffs & change set have been reviewed, the change can be applied and
  stack events monitored.
- Stack events will be displayed until an end state is reached.

Stack parameters can be dynamically resolved at runtime using one of the
built in parameter resolvers. Parameters can be sourced from GPG encrypted YAML
files, other stacks outputs, by querying various AWS API's to get resource ARNs
etc.

## Installation

System-wide: `gem install stack_master`

With bundler:

- Add `gem 'stack_master'` to your Gemfile.
- Run `bundle install`
- Run `bundle exec stack_master init` to generate a directory structure and stack_master.yml file

## Configuration

Stacks are defined inside a `stack_master.yml` YAML file. When running
`stack_master`, it is assumed that this file will exist in the current working
directory, or that the file is passed in with `--config
/path/to/stack_master.yml`.  Here's an example configuration file:

```
region_aliases:
  production: us-east-1
  staging: ap-southeast-2
stack_defaults:
  tags:
    application: my-awesome-app
region_defaults:
  us-east-1:
    secret_file: production.yml.gpg
    tags:
      environment: production
    notification_arns:
      - test_arn
  ap-southeast-2:
    secret_file: staging.yml.gpg
    tags:
      environment: staging
stacks:
  production:
    myapp-vpc:
      template: myapp_vpc.rb
      tags:
        purpose: front-end
    myapp-db:
      template: myapp_db.rb
      stack_policy_file: db_stack_policy.json
      tags:
        purpose: back-end
    myapp-web:
      template: myapp_web.rb
      tags:
        purpose: front-end
  staging:
    myapp-vpc:
      template: myapp_vpc.rb
      tags:
        purpose: front-end
    myapp-db:
      template: myapp_db.rb
      tags:
        purpose: back-end
    myapp-web:
      template: myapp_web.rb
      tags:
        purpose: front-end
  eu-central-1:
    myapp-vpc:
      template: myapp_vpc.rb
      tags:
        purpose: vpc
```

## S3

StackMaster can optionally use S3 to store the templates before creating a stack. Optionally, you can use a skip_upload flag to reuse existing S3 template. This allows you to decouple template code from management of templates.
This requires to configure an S3 bucket in stack_master.yml:

```yaml
stack_defaults:
  s3:
    bucket: my_bucket_name
    prefix: cfn_templates/my-awesome-app
    region: us-west-2
    skip_upload: true # Default to false
```

Additional files can be configured to be uploaded to S3 alongside the templates:
```yaml
stacks:
  production:
    myapp-vpc:
      template: myapp_vpc.rb
      files:
        - userdata.sh
```
## Directories

- `templates` - CloudFormation, SparkleFormation or CfnDsl templates.
- `polices` - Stack policies.
- `parameters` - Parameters as YAML files.
- `secrets` - GPG encrypted secret files.
- `policies` - Stack policy JSON files.

## Templates

StackMaster supports CloudFormation templates in plain JSON or YAML. Any `.yml` or `.yaml` file will be processed as
YAML. While any `.json` file will be processed as JSON.

### Ruby DSLs
By default, any template ending with `.rb` will be processed as a [SparkleFormation](https://github.com/sparkleformation/sparkle_formation)
template. However, if you want to use [CfnDsl](https://github.com/stevenjack/cfndsl) templates you can add
the following lines to your `stack_master.yml`.

```
template_compilers:
  rb: cfndsl
```

## Parameters

Parameters are loaded from multiple YAML files, merged from the following lookup paths:

- parameters/[stack_name].yml
- parameters/[region]/[underscored_stack_name].yml
- parameters/[region_alias]/[underscored_stack_name].yml

A simple parameter file could look like this:

```
key_name: myapp-us-east-1
```

Keys in parameter files are automatically converted to camel case.

## Parameter Resolvers

Parameter values can be sourced dynamically using parameter resolvers.

One benefit of using parameter resolvers instead of hard coding values like VPC
ID's and resource ARNs is that the same configuration works cross
region/account, even though the resolved values will be different.

### Stack Output

The stack output parameter resolver looks up outputs from other stacks in the
same region. The expected format is `[stack-name]/[OutputName]`.

```yaml
vpc_id:
  stack_output: my-vpc-stack/VpcId
```

This is the most used parameter resolver because it enables stacks to be split
up into their separated concerns (VPC, web, database etc) with outputs feeding
into parameters of dependent stacks.

### Secret

The secret parameters resolver expects a `secret_file` to be defined in the
stack definition which is a GPG encrypted YAML file. Once decrypted and parsed,
the value provided to the secret resolver is used to lookup the associated key
in the secret file. A common use case for this is to store database passwords.

stack_master.yml:

```yaml
stacks:
  us-east-1:
    my_app:
      template: my_app.json
      secret_file: production.yml.gpg
```

secrets/production.yml.gpg, when decrypted:

```yaml
db_password: my-password
```

parameters/my_app.yml:

```yaml
db_password:
  secret: db_password
```

### Security Group

Looks up a security group by name and returns the ARN.

```yaml
ssh_sg:
  security_group: SSHSecurityGroup
```

### Security Groups

An array of security group names can also be provided.
```yaml
ssh_sg:
  security_groups:
    - SSHSecurityGroup
    - WebAccessSecurityGroup
```

### SNS Topic

Looks up an SNS topic by name and returns the ARN.

```yaml
notification_topic:
  sns_topic_name: PagerDuty
```

### Latest AMI by Tag

Looks up the latest AMI ID by a given set of tags.

```yaml
web_ami:
  latest_ami_by_tags: role=web,application=myapp
```

Note that the corresponding array resolver is named `latest_amis_by_tags`

### Latest AMI by attribute

Looks up the latest AMI ID by a given set of attributes. By default it will only return AMIs from the account the stack is created in, but you can specify the account ID or [certain keywords mentioned in the aws documentation](http://docs.aws.amazon.com/AWSEC2/latest/CommandLineReference/ApiReference-cmd-DescribeImages.html)

This selects the latest wily hvm AMI from Ubuntu (using the account id):

```yaml
bastion_ami:
  latest_ami:
    owners: 099720109477
    filters:
      name: ubuntu/images/hvm/ubuntu-wily-15.10-amd64-server-*
```

A set of possible attributes is available in the [AWS documentation](https://docs.aws.amazon.com/sdkforruby/api/Aws/EC2/Client.html#describe_images-instance_method)

Any value can be an array of possible matches.

### Custom parameter resolvers

New parameter resolvers can be created in a separate gem.

To create a resolver named my_resolver:
  * Create a new gem using your favorite tool
  * The gem structure must contain the following path:
```
lib/stack_master/parameter_resolvers/my_resolver.rb
```
  * That file need to contain a class named `StackMaster::ParameterResolvers::MyResolver`
    that implements a `resolve` method and an initializer taking 2 parameters :
```ruby
module StackMaster
  module ParameterResolvers
    class MyResolver < Resolver
      array_resolver # Also create a MyResolvers resolver to handle arrays

      def initialize(config, stack_definition)
        @config = config
        @stack_definition = stack_definition
      end

      def resolve(value)
        value
      end
    end
  end
end
```
  * Note that the filename and classname are both derived from the resolver name
    passed in the parameter file. In our case, the parameters YAML would look like:
```yaml
vpc_id:
  my_resolver: dummy_value
```

## Resolver Arrays

Most resolvers support taking an array of values that will each be resolved.
Unless stated otherwise in the documentation, the array version of the
resolver will be named with the [pluralized](http://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-pluralize) 
name of the original resolver.

When creating a new resolver, one can automatically create the array resolver by adding a `array_resolver` statement
in the class definition, with an optional class name if different from the default one.
```
module StackMaster
  module ParameterResolvers
    class MyResolver < Resolver
      array_resolver class_name: 'MyCustomArrayResolver'
      ...
    end
  end
end
```
In that example, using the array resolver would look like:
```
my_parameter:
  my_custom_array_resolver:
    - value1
    - value2
```

Array parameter values can include nested parameter resolvers.

For example, given the following parameter definition:
```
my_parameter:
  - stack_output: my-stack/output # value resolves to 'value1'
  - value2
```
The parameter value will resolve to:
```
my_parameter: 'value1,value2'
```

## ERB Template Files in SparkleFormation templates

An extension to SparkleFormation is the `user_data_file!` method, which evaluates templates in `templates/user_data/[file_name]`. Most of the usual SparkleFormation methods are available in user data templates. Example:

```
# templates/user_data/app.erb
REGION=<%= region! %>
ROLE=<%= role %>
```

And used like this in SparkleFormation templates:

```
# templates/app.rb
  user_data user_data_file!('app.erb', role: :worker)
```

You can also use the `joined_file!` method which evaluates templates in `templates/config/[file_name]`. It is similar to `user_data_file!` but doesn't do base64 encoding. Example:

```
# templates/config/someconfig.conf.erb
my_variable=<%= ref!(:foo) %>
my_other_variable=<%= account_id! %>
```

```
# templates/ecs_task.rb
container_definitions array!(
  -> {
    command array!(
      "-e",
      joined_file!('someconfig.conf.erb')
    )
    ...
  }
)
```

## Commands

```bash
stack_master help # Display up to date docs on the commands available
stack_master init # Initialises a directory structure and stack_master.yml file
stack_master list # Lists stack definitions
stack_master apply [region-or-alias] [stack-name] # Create or update a stack
stack_master apply [region-or-alias] [stack-name] [region-or-alias] [stack-name] # Create or update multiple stacks
stack_master apply [region-or-alias] # Create or update stacks in the given region
stack_master apply # Create or update all stacks
stack_master --changed apply # Create or update all stacks that have changed
stack_master --yes apply [region-or-alias] [stack-name] # Create or update a stack non-interactively (forcing yes)
stack_master diff [region-or-alias] [stack-name] # Display a stack tempalte and parameter diff
stack_master delete [region-or-alias] [stack-name] # Delete a stack
stack_master events [region-or-alias] [stack-name] # Display events for a stack
stack_master outputs [region-or-alias] [stack-name] # Display outputs for a stack
stack_master resources [region-or-alias] [stack-name] # Display outputs for a stack
stack_master status # Displays the status of each stack
```

## Applying updates

The apply command does the following:

- Compiles the proposed stack template and resolves parameters.
- Fetches the current state of the stack from CloudFormation.
- Displays a diff of the current stack and the proposed stack.
- Creates a change set and displays the actions that CloudFormation will take
  to perform the update (if the stack already exists).
- Asks if the update should continue.
- If yes, the API calls are made to update or create the stack.
- Stack events are displayed until CloudFormation has finished applying the changes.

Demo:

![Apply Demo](/apply_demo.gif?raw=true)

## Maintainers

- [Steve Hodgkiss](https://github.com/stevehodgkiss)
- [Glen Stampoultzis](https://github.com/gstamp)

## License

StackMaster uses the MIT license. See [LICENSE.txt](https://github.com/envato/stack_master/blob/master/LICENSE.txt) for details.

## Contributing

1. Fork it ( http://github.com/envato/stack_master/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
