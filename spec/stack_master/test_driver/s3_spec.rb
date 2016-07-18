RSpec.describe StackMaster::TestDriver::S3 do
  subject(:s3_driver) { described_class.new }
  let(:bucket) { 'test-bucket' }
  let(:prefix) { 'test-prefix' }
  let(:files) { { 'test-file' => { path: 'path', body: 'body' } } }
  let(:region) { 'us-east-1' }

  it 'uploads and finds files' do
    s3_driver.upload_files(bucket: bucket,
                           prefix: prefix,
                           region: region,
                           files: files)
    file = s3_driver.find_file(bucket: bucket,
                               object_key: [prefix, 'test-file'].compact.join('/'))
    expect(file).to be
  end
end
