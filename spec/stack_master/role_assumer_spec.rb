RSpec.describe StackMaster::RoleAssumer do
  subject(:role_assumer) { described_class.new }

  let(:account) { '1234567890' }
  let(:role) { 'my-role' }
  let(:role_arn) { "arn:aws:iam::#{account}:role/#{role}" }

  describe '#assume_role' do
    let(:assume_role) { role_assumer.assume_role(account, role, &my_block) }
    let(:my_block) { -> { "I've been called!" } }
    let(:credentials) { instance_double(Aws::AssumeRoleCredentials) }

    before do
      allow(Aws::AssumeRoleCredentials).to receive(:new).and_return(credentials)
      StackMaster.cloud_formation_driver.set_region('us-east-1')
    end

    it 'calls the assume role API once' do
      expect(Aws::AssumeRoleCredentials).to receive(:new).with(
        region: instance_of(String),
        role_arn: role_arn,
        role_session_name: instance_of(String)
      ).once

      assume_role
    end

    it 'calls the passed in block once' do
      expect { |b| role_assumer.assume_role(account, role, &b) }.to yield_control.once
    end

    it "returns the block's return value" do
      expect(assume_role).to eq("I've been called!")
    end

    it 'assumes the role before calling block' do
      expect(Aws::AssumeRoleCredentials).to receive(:new).with(
        region: instance_of(String),
        role_arn: role_arn,
        role_session_name: instance_of(String)
      ).ordered
      expect(my_block).to receive(:call).ordered

      assume_role
    end

    it "uses the cloudformation driver's region" do
      StackMaster.cloud_formation_driver.set_region('my-region')
      expect(Aws::AssumeRoleCredentials).to receive(:new).with(
        region: 'my-region',
        role_arn: instance_of(String),
        role_session_name: instance_of(String)
      )

      assume_role
    end

    context 'when no block is specified' do
      let(:my_block) { nil }

      it 'raises an error' do
        expect { assume_role }.to raise_error(StackMaster::RoleAssumer::BlockNotSpecified)
      end
    end

    context 'when account is nil' do
      let(:account) { nil }

      it 'when raises an error' do
        expect { assume_role }.to raise_error(ArgumentError, "Both 'account' and 'role' are required to assume a role")
      end
    end

    context 'when role is nil' do
      let(:role) { nil }

      it 'raises an error' do
        expect { assume_role }.to raise_error(ArgumentError, "Both 'account' and 'role' are required to assume a role")
      end
    end

    context 'setting aws credentials' do
      let(:new_aws_config) { {} }

      before do
        allow(Aws.config).to receive(:deep_dup).and_return(new_aws_config)
      end

      it 'updates the global Aws config with the assumed role credentials' do
        expect(new_aws_config[:credentials]).to eq(nil)

        assume_role

        expect(new_aws_config[:credentials]).to eq(credentials)
      end

      it 'restores the original Aws.config after calling block' do
        old_config = Aws.config

        assume_role

        expect(Aws.config).to eq(old_config)
      end
    end

    context 'CloudFormation driver' do
      let(:new_driver) { StackMaster.cloud_formation_driver.class.new }

      before do
        allow(StackMaster::AwsDriver::CloudFormation).to receive(:new).and_return(new_driver)
      end

      it 'updates the global cloudformation driver' do
        old_driver = StackMaster.cloud_formation_driver
        expect(StackMaster).to receive(:cloud_formation_driver=).with(new_driver).once.and_call_original.ordered
        expect(StackMaster).to receive(:cloud_formation_driver=).with(old_driver).once.and_call_original.ordered

        assume_role
      end

      it 'restores the original cloudformation driver after calling block' do
        old_driver = StackMaster.cloud_formation_driver

        assume_role

        expect(StackMaster.cloud_formation_driver).to eq(old_driver)
      end
    end

    describe 'when called multiple times' do
      context 'with the same account and role' do
        it 'assumes the role once' do
          expect(Aws::AssumeRoleCredentials).to receive(:new).with(
            region: instance_of(String),
            role_arn: role_arn,
            role_session_name: instance_of(String)
          ).once

          role_assumer.assume_role(account, role, &my_block)
          role_assumer.assume_role(account, role, &my_block)
        end
      end

      context 'with a different account' do
        it 'assumes each role once' do
          expect(Aws::AssumeRoleCredentials).to receive(:new).with(
            region: instance_of(String),
            role_arn: role_arn,
            role_session_name: instance_of(String)
          ).once
          expect(Aws::AssumeRoleCredentials).to receive(:new).with(
            region: instance_of(String),
            role_arn: "arn:aws:iam::another-account:role/#{role}",
            role_session_name: instance_of(String)
          ).once

          role_assumer.assume_role(account, role, &my_block)
          role_assumer.assume_role('another-account', role, &my_block)
        end
      end

      context 'with a different role' do
        it 'assumes each role once' do
          expect(Aws::AssumeRoleCredentials).to receive(:new).with(
            region: instance_of(String),
            role_arn: role_arn,
            role_session_name: instance_of(String)
          ).once
          expect(Aws::AssumeRoleCredentials).to receive(:new).with(
            region: instance_of(String),
            role_arn: "arn:aws:iam::#{account}:role/another-role",
            role_session_name: instance_of(String)
          ).once

          role_assumer.assume_role(account, role, &my_block)
          role_assumer.assume_role(account, 'another-role', &my_block)
        end
      end
    end
  end
end
