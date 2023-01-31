RSpec.describe StackMaster::AwsDriver::S3 do
  let(:region) { 'us-east-1' }
  let(:bucket) { 'bucket' }
  let(:s3) { Aws::S3::Client.new({ stub_responses: true }) }
  subject(:s3_driver) { StackMaster::AwsDriver::S3.new }

  before do
    allow(Aws::S3::Client).to receive(:new).and_return(s3)
  end

  describe '#upload_files' do
    context 'when set_region is called' do
      it 'defaults to that region' do
        s3_driver.set_region('default')
        expect(Aws::S3::Client).to receive(:new).with({ region: 'default' }).and_return(s3)
        files = {
          'template' => {
            path: 'spec/fixtures/templates/myapp_vpc.json',
            body: 'file content'
          }
        }
        s3_driver.upload_files(bucket: 'b',
                               files: files)
      end
    end

    context 'when called with a prefix' do
      let(:options) do
        {
          bucket: 'bucket',
          region: 'region',
          prefix: 'prefix',
          files: {'template' => {
            path: 'spec/fixtures/templates/myapp_vpc.json',
            body: 'file content'
            }
          }
        }
      end

      it 'uploads files under a prefix' do
        expect(s3).to receive(:put_object).with(
          {
            bucket: 'bucket',
            key: 'prefix/template',
            body: 'file content',
            metadata: {
              md5: "d10b4c3ff123b26dc068d43a8bef2d23"
            }
          }
        )
        s3_driver.upload_files(**options)
      end
    end

    context 'when called without a prefix' do
      let(:options) do
        {
          bucket: 'bucket',
          region: 'region',
          files: {'template' => {
            :path => 'spec/fixtures/templates/myapp_vpc.json',
            :body => 'file content'
            }
          }
        }
      end

      it 'uploads files under the bucket root' do
        expect(s3).to receive(:put_object).with(
          {
            bucket: 'bucket',
            key: 'template',
            body: 'file content',
            metadata: {
              md5: "d10b4c3ff123b26dc068d43a8bef2d23"
            }
          }
        )
        s3_driver.upload_files(**options)
      end
    end

    context 'when called with files in a subfolder' do
      let(:options) do
        {
          bucket: 'bucket',
          region: 'region',
          prefix: 'prefix',
          files: {'template' => {
            :path => 'spec/fixtures/templates/myapp_vpc.json',
            :body => 'file content'
            }
          }
        }
      end

      it 'uploads files under the prefix' do
        expect(s3).to receive(:put_object).with(
          {
            bucket: 'bucket',
            key: 'prefix/template',
            body: 'file content',
            metadata: {
              md5: "d10b4c3ff123b26dc068d43a8bef2d23"
            }
          }
        )
        s3_driver.upload_files(**options)
      end
    end

    context 'when called with several files' do
      let(:options) do
        {
          bucket: 'bucket',
          region: 'region',
          files: {
            'template1' => {
              :path => 'spec/fixtures/templates/myapp_vpc.json',
              :body => 'file content'
            },
            'template2' => {
              :path => 'spec/fixtures/templates/myapp_vpc.json',
              :body => 'file content'
            }
          }
        }
      end

      it 'uploads all the files' do
        expect(s3).to receive(:put_object).with(
          {
            bucket: 'bucket',
            key: 'template1',
            body: 'file content',
            metadata: {
              md5: "d10b4c3ff123b26dc068d43a8bef2d23"
            }
          }
        )
        expect(s3).to receive(:put_object).with(
          {
            bucket: 'bucket',
            key: 'template2',
            body: 'file content',
            metadata: {
              md5: "d10b4c3ff123b26dc068d43a8bef2d23"
            }
          }
        )
        s3_driver.upload_files(**options)
      end
    end
  end
end
