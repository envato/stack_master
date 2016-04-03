RSpec.describe StackMaster::AwsDriver::S3 do
  let(:region) { 'us-east-1' }
  let(:bucket) { 'bucket' }
  subject(:s3_driver) { StackMaster::AwsDriver::S3.new }

  describe '#upload_files' do
    before do
      allow(File).to receive(:read).and_return('file content')
    end

    context 'when called with a prefix' do
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

      it 'uploads files under a prefix' do
        expect(s3_driver).to receive(:put_object).with(bucket: 'bucket',
                                                       key: 'prefix/template',
                                                       body: 'file content',
                                                       metadata: {md5: "d10b4c3ff123b26dc068d43a8bef2d23"})
        s3_driver.upload_files(options)
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
        expect(s3_driver).to receive(:put_object).with(bucket: 'bucket',
                                                       key: 'template',
                                                       body: 'file content',
                                                       metadata: {md5: "d10b4c3ff123b26dc068d43a8bef2d23"})
        s3_driver.upload_files(options)
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
        expect(s3_driver).to receive(:put_object).with(bucket: 'bucket',
                                                       key: 'prefix/template',
                                                       body: 'file content',
                                                       metadata: {md5: "d10b4c3ff123b26dc068d43a8bef2d23"})
        s3_driver.upload_files(options)
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
        expect(s3_driver).to receive(:put_object).with(bucket: 'bucket',
                                                       key: 'template1',
                                                       body: 'file content',
                                                       metadata: {md5: "d10b4c3ff123b26dc068d43a8bef2d23"})
        expect(s3_driver).to receive(:put_object).with(bucket: 'bucket',
                                                       key: 'template2',
                                                       body: 'file content',
                                                       metadata: {md5: "d10b4c3ff123b26dc068d43a8bef2d23"})
        s3_driver.upload_files(options)
      end
    end
  end
end
