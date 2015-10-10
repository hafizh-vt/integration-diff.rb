# IntegrationDiffRails

Currently this supports only RSpec.

### Installation

```
gem "integration-diff-rails", git: "git@github.com:code-mancers/integration-diff-rails"
```

### Configuration

Include `integration-diff-rails` in your rspec `spec_helper` and configure 3 variables
which will be used while taking screenshots.

```
IntegrationDiffRails.configure do |config|
  # configure domain to which all images have to be uploaded.
  config.base_uri = "http://idf.dev"

  # configure project name to which images belong to.
  config.project_name = "idf"

  # configure js driver which is used for taking screenshots.
  config.javascript_driver = "poltergeist"
end
```

After configuration, include `IntegrationDiffRails::Rspec` in your `spec_helper` and
configure before and after suite so that suite interacts with the service.


```
Rspec.configure do |config|
  config.include IntegrationDiffRails::Rspec

  config.before(:suite)
    IntegrationDiffRails.start_run
  end

  config.after(:suite)
    IntegrationDiffRails.wrap_run
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
    idiff.take_screenshot("unique-identifier")
  end
end
```
