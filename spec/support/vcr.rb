require "vcr"

def vcr_record_mode
  if ENV["VCR_RECORD"] == "1"
    :new_episodes
  else
    :none
  end
end

ENV["POST_HUBSPOT_HAPI_KEY"] ||= "demo"

VCR.configure do |c|
  c.cassette_library_dir = "#{RSPEC_ROOT}/fixtures/vcr_cassettes"
  c.hook_into :webmock
  c.default_cassette_options = { record: vcr_record_mode }
  c.filter_sensitive_data("<HAPI_KEY>") { ENV.fetch("HUBSPOT_HAPI_KEY", "demo") }
  c.filter_sensitive_data("<POST_HAPI_KEY>") { ENV.fetch("POST_HUBSPOT_HAPI_KEY") }
end
