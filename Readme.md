# IntegrationDiff

Currently this supports only RSpec.

### Installation

```rb
gem 'integration-diff'
```

### Configuration

Include `integration-diff` in your rspec `spec_helper` and configure 6 variables
which will be used while taking screenshots. Make sure that `enable_service` is
set to true if images need to be uploaded.

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
  config.enable_service = !!ENV["IDIFF_ENABLE"]

  # configure logger to log messages. optional.
  config.logger = Rails.logger
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

In your specs, simply use `idiff` helper which has bunch of config utilities.

First, you should specify environment details under which screenshots are
taken. There are 6 parameters which can be configured.

Parameter|Explanation
---------|-----------
browser  | which browser is used to take screenshots. default: 'firefox'
         | supported: firefox, chrome, safari, ie, opera
device   | which device is used to take screenshots. default: 'desktop'
         | supported: desktop, laptop, tablet, phone
os       | which os is used to take screenshots. default: 'linux'
         | supported: android, ios, windows, osx, linux
browser_version | (optional) version of browser used, for eg: '46' for firefox
device_name     | (optional) name of device, for eg: 'MacBook Air'
os_version      | (optional) version of os used, for eg: '10.11'


They can be configured using `idiff` helper while running specs. For eg:

```rb
idiff.browser = 'firefox'
idiff.device = 'laptop'
idiff.os = 'osx'
idiff.browser_version = '46'
idiff.device_name = 'MBA'
idiff.os_version = '10.11.5'
```

Also, `idiff` can used to take screenshots also. Make sure that you pass
unique identifier to screenshots that you take. unique identifier helps
in differentiating this screenshot taken from other screenshots for a
given set of `browser`, `device`, and `os`.


```rb
describe "Landing page" do
  it "has a big banner" do
    visit root_path

    idiff.browser = 'chrome'
    idiff.screenshot("unique-identifier")
  end
end
```

Since there is flexibility to specify `browser`, `device`, and `os` while
running specs dynamically (unlike specifying `project_name`), you can run
all your specs in a loop by changing `browser`, `device` and `os` by
changing selenium driver, or changing viewport etc. Flexibility for your
service!


### Concurrency

By default, when all the screenshots are collected, and before suite ends, this
gem will upload all the screenshots taken. `IntegrationDiff.wrap_run` is the
method responsible for the same.

However, if you want to upload screenshots as and when they are taken, this gem
has soft dependency on `concurrent-ruby` gem. Make sure that this gem is
**required** before capturing screenshots, and see the magic yourself :)
