RSpec.describe(StackMaster::CloudFormationInterpolatingEruby) do
  describe('#evaluate') do
    subject(:evaluate) { described_class.new(user_data).evaluate }

    context('given a simple user data script') do
      let(:user_data) { <<~SHELL }
        #!/bin/bash

        REGION=ap-southeast-2
        echo $REGION
      SHELL

      it 'returns an array of lines' do
        expect(evaluate).to eq([
          "#!/bin/bash\n",
          "\n",
          "REGION=ap-southeast-2\n",
          "echo $REGION\n",
        ])
      end
    end

    context('given a user data script referring parameters') do
      let(:user_data) { <<~SHELL }
        #!/bin/bash
        <%= { 'Ref' => 'Param1' } %> <%= { 'Ref' => 'Param2' } %>
      SHELL

      it 'includes CloudFormation objects in the array' do
        expect(evaluate).to eq([
          "#!/bin/bash\n",
          { 'Ref' => 'Param1' },
          ' ',
          { 'Ref' => 'Param2' },
          "\n",
        ])
      end
    end
  end

  describe('.evaluate_file') do
    subject(:evaluate_file) { described_class.evaluate_file('my/userdata.sh') }

    context('given a simple user data script file') do
      before { allow(File).to receive(:read).with('my/userdata.sh').and_return(<<~SHELL) }
        #!/bin/bash

        REGION=ap-southeast-2
        echo $REGION
      SHELL

      it 'returns an array of lines' do
        expect(evaluate_file).to eq([
          "#!/bin/bash\n",
          "\n",
          "REGION=ap-southeast-2\n",
          "echo $REGION\n",
        ])
      end
    end
  end
end
