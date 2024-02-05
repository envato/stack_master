RSpec.describe(StackMaster::CloudFormationTemplateEruby) do
  subject(:evaluate) do
    eruby = described_class.new(template)
    eruby.evaluate(eruby)
  end

  describe('.user_data_file') do
    context('given a template that loads a simple user data script file') do
      let(:template) { <<~YAML}
        Resources:
          LaunchConfig:
            Type: 'AWS::AutoScaling::LaunchConfiguration'
            Properties:
              UserData: <%= user_data_file('my/userdata.sh') %>
      YAML

      before do
        allow(File).to receive(:read).with('my/userdata.sh').and_return(<<~SHELL)
          #!/bin/bash

          REGION=ap-southeast-2
          echo $REGION
        SHELL
      end

      it 'embeds the script in the evaluated CFN template' do
        expect(evaluate).to eq(<<~YAML)
          Resources:
            LaunchConfig:
              Type: 'AWS::AutoScaling::LaunchConfiguration'
              Properties:
                UserData: {
            "Fn::Base64": {
              "Fn::Join": [
                "",
                [
                  "#!/bin/bash\\n",
                  "\\n",
                  "REGION=ap-southeast-2\\n",
                  "echo $REGION\\n"
                ]
              ]
            }
          }
        YAML
      end
    end

    context('given a template that loads a user data script file that includes another file') do
      let(:template) { <<~YAML}
        Resources:
          LaunchConfig:
            Type: 'AWS::AutoScaling::LaunchConfiguration'
            Properties:
              UserData: <%= user_data_file('my/userdata.sh') %>
      YAML

      before do
        allow(File).to receive(:read).with('my/userdata.sh').and_return(<<~SHELL)
          #!/bin/bash
          echo 'Hello from userdata.sh'
          <%= user_data_file_as_lines('my/other.sh') %>
        SHELL
        allow(File).to receive(:read).with('my/other.sh').and_return(<<~SHELL)
          echo 'Hello from other.sh'
        SHELL
      end

      it 'embeds the script in the evaluated CFN template' do
        expect(evaluate).to eq(<<~YAML)
          Resources:
            LaunchConfig:
              Type: 'AWS::AutoScaling::LaunchConfiguration'
              Properties:
                UserData: {
            "Fn::Base64": {
              "Fn::Join": [
                "",
                [
                  "#!/bin/bash\\n",
                  "echo 'Hello from userdata.sh'\\n",
                  "echo 'Hello from other.sh'\\n",
                  "\\n"
                ]
              ]
            }
          }
        YAML
      end
    end
  end

  describe('.include_file') do
    context('given a template that loads a lambda script') do
      let(:template) { <<~YAML}
        Resources:
          Function:
            Type: 'AWS::Lambda::Function'
            Properties:
              Code:
                ZipFile: <%= include_file('my/lambda.sh') %>
      YAML

      before do
        allow(File).to receive(:read).with('my/lambda.sh').and_return(<<~SHELL)
          #!/bin/bash

          echo 'Hello, world!'
        SHELL
      end

      it 'embeds the script in the evaluated CFN template' do
        expect(evaluate).to eq(<<~YAML)
          Resources:
            Function:
              Type: 'AWS::Lambda::Function'
              Properties:
                Code:
                  ZipFile: "#!/bin/bash\\n\\necho 'Hello, world!'\\n"
        YAML
      end
    end
  end
end
