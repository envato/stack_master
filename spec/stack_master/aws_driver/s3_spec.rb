RSpec.describe StackMaster::AwsDriver::S3 do
  let(:base_dir) { File.expand_path('spec/fixtures') }
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
          files: [{'template' => 'templates/myapp_vpc.json'}]
        }
      end

      it 'uploads files under a prefix' do
        expect(s3_driver).to receive(:put_object).with(bucket: 'bucket',
                                                       key: 'prefix/template',
                                                       body: 'file content',
                                                       metadata: {md5: "8a80554c91d9fca8acb82f023de02f11"})
        s3_driver.upload_files(options)
      end
    end

    context 'when called without a prefix' do
      let(:options) do
        {
          bucket: 'bucket',
          region: 'region',
          files: [{'template' => 'templates/myapp_vpc.json'}]
        }
      end

      it 'uploads files under the bucket root' do
        expect(s3_driver).to receive(:put_object).with(bucket: 'bucket',
                                                       key: 'template',
                                                       body: 'file content',
                                                       metadata: {md5: "8a80554c91d9fca8acb82f023de02f11"})
        s3_driver.upload_files(options)
      end
    end

    context 'when called with files in a subfolder' do
      let(:options) do
        {
          bucket: 'bucket',
          region: 'region',
          prefix: 'prefix',
          files: [{'template' => 'templates/myapp_vpc.json'}]
        }
      end

      it 'uploads files under the prefix' do
        expect(s3_driver).to receive(:put_object).with(bucket: 'bucket',
                                                       key: 'prefix/template',
                                                       body: 'file content',
                                                       metadata: {md5: "8a80554c91d9fca8acb82f023de02f11"})
        s3_driver.upload_files(options)
      end
    end

    context 'when called with several files' do
      let(:options) do
        {
          bucket: 'bucket',
          region: 'region',
          files: [{'template1' => 'templates/myapp_vpc.json'}, {'template2' => 'templates/myapp_vpc.json'}]
        }
      end

      it 'uploads all the files' do
        expect(s3_driver).to receive(:put_object).with(bucket: 'bucket',
                                                       key: 'template1',
                                                       body: 'file content',
                                                       metadata: {md5: "8a80554c91d9fca8acb82f023de02f11"})
        expect(s3_driver).to receive(:put_object).with(bucket: 'bucket',
                                                       key: 'template2',
                                                       body: 'file content',
                                                       metadata: {md5: "8a80554c91d9fca8acb82f023de02f11"})
        s3_driver.upload_files(options)
      end
    end
  end
end
