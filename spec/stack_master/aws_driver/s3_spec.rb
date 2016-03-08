RSpec.describe StackMaster::AwsDriver::S3 do
  subject(:s3_driver) { StackMaster::AwsDriver::S3.new }

  describe '#upload_files' do
    before do
      allow(File).to receive(:read).and_return('file content')
    end

    context 'when called with a prefix' do
      let(:options) do
        {
          bucket: 'bucket',
          prefix: 'prefix',
          files: ['file']
        }
      end

      it 'uploads files under a prefix' do
        expect(s3_driver).to receive(:put_object).with(bucket: 'bucket',
                                                       key: 'prefix/file',
                                                       body: 'file content')
        s3_driver.upload_files(options)
      end
    end

    context 'when called without a prefix' do
      let(:options) do
        {
          bucket: 'bucket',
          files: ['file']
        }
      end

      it 'uploads files under the bucket root' do
        expect(s3_driver).to receive(:put_object).with(bucket: 'bucket',
                                                       key: 'file',
                                                       body: 'file content')
        s3_driver.upload_files(options)
      end
    end

    context 'when called with files in a subfolder' do
      let(:options) do
        {
          bucket: 'bucket',
          prefix: 'prefix',
          files: ['folder/file']
        }
      end

      it 'uploads files under the prefix' do
        expect(s3_driver).to receive(:put_object).with(bucket: 'bucket',
                                                       key: 'prefix/file',
                                                       body: 'file content')
        s3_driver.upload_files(options)
      end
    end

    context 'when called with several files' do
      let(:options) do
        {
          bucket: 'bucket',
          files: ['file1', 'file2']
        }
      end

      it 'uploads all the files' do
        expect(s3_driver).to receive(:put_object).with(bucket: 'bucket',
                                                       key: 'file1',
                                                       body: 'file content')
        expect(s3_driver).to receive(:put_object).with(bucket: 'bucket',
                                                       key: 'file2',
                                                       body: 'file content')
        s3_driver.upload_files(options)
      end
    end
  end
end
