require "webmock/rspec"
require "vcr"

VCR.configure do |c|
  c.hook_into :webmock
  c.configure_rspec_metadata!

  c.cassette_library_dir = "spec/cassettes"
  c.default_cassette_options = { record: :once }
end
