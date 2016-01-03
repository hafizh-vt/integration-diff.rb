# IntegrationDiff

Currently this supports only RSpec.

### Installation

```rb
gem "integration-diff-rails", git: "git@github.com:code-mancers/integration-diff-rails"
```

### Configuration

Include `integration-diff-rails` in your rspec `spec_helper` and configure 5 variables
which will be used while taking screenshots. Make sure that `mock_service` is set to
to proper value, as its very important.

**NOTE:** Make sure that that project exists in service with `project_name`. Also
api key can be obtained by loggin into service and visiting `/api_key`.


```rb
IntegrationDiff.configure do |config|
  # configure domain to which all images have to be uploaded.
  config.base_uri = "http://idf.dev"

  # configure project name to which images belong to.
  config.project_name = "idf"

  # configure api_key required to authorize api access
  config.api_key = ENV["IDIFF_API_KEY"]

  # configure js driver which is used for taking screenshots.
  config.javascript_driver = "poltergeist"

  # configure service to mock capturing and uploading screenshots
  config.mock_service = ENV["IDIFF_ENABLE"].blank?
end
```

After configuration, include `IntegrationDiff::Dsl` in your `spec_helper` and
configure before and after suite so that suite interacts with the service.


```rb
RSpec.configure do |config|
  config.include IntegrationDiff::Dsl

  config.before(:suite) do
    IntegrationDiff.start_run
  end

  config.after(:suite) do
    IntegrationDiff.wrap_run
  end
end
```

### Usage

In your specs, simply use `idiff` helper. make sure that you pass unique identifier
to screenshots that you take. unique identifier helps in differentiating this
screenshot taken from other screenshots.


```rb
describe "Landing page" do
  it "has a big banner" do
    visit root_path
    idiff.screenshot("unique-identifier")
  end
end
```
