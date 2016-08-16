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


### Multiple Runs

All the guides provided below are meant for Ruby on Rails. 

In order to run multiple runs automatically with different drivers, there are several 
things that we need to do. 

- setting up the drivers
- configuration in `spec_helper.rb`
- create a rake task

Before doing all of the task above, we should set the environment variables needed for the task. Don't bother to set `SAUCE_USERNAME` and `SAUCE_KEY` if you don't use SauceLabs Drivers.

##### Environment Variables :

```rb
export IDIFF_ENABLE=true             # for enabling integration diff in multiple runs
export IDIFF_API_KEY=888888888888888 # api key for integration diff
export SAUCE_USERNAME=myusername     # SauceLabs username (if you're using Sauce drivers)
export SAUCE_KEY=6768786696766669679 # SauceLabs key (if you're using Sauce drivers)
```

In this build we support two drivers. The default one from Capybara and also remote drivers 
from SauceLabs. To use the default Capybara drivers, simply register them in a file (for example 
`capybara_driver.rb`) and put them in `spec/supports/` to be required later in `spec_helper.rb`.

##### Default Driver :
```rb
case ENV['IDIFF_DRIVER']

when "firefox"

  # register the driver here 
  Capybara.register_driver :used_driver do |app|
    Capybara::Selenium::Driver.new(app, :browser => :firefox)
  end
  
else 
  #  default driver if not specified
  Capybara.register_driver :used_driver do |app|
    Capybara::Selenium::Driver.new(app, :browser => :firefox)
  end
end

# register the selected drivers as current driver used
Capybara.current_driver = :used_driver

```

##### SauceLabs Driver :
```rb
case ENV['IDIFF_DRIVER']

when "saucelabs"

  # URL for SauceLabs drivers
  sauce_url = "http://#{ENV['SAUCE_USERNAME']}:#{ENV['SAUCE_KEY']}@localhost:4445/wd/hub"

  # register your driver capabilities here
  # Remember, only SauceLabs capability formats that are accepted
  capabilities = {
      :platform => "Windows 8",
      :browserName => "Chrome",
      :version => "31",
      :screen_resolution => "1280x1024",

      :name => IntegrationDiff.name_test( ENV['IDIFF_DRIVER'] )
  }

  # setting up the driver over here
  # This settings will invoke the test environment over the remote
  @browser = {
    browser: :remote,
    url: sauce_url,
    desired_capabilities: capabilities
  }

  # register your driver over here 
  # This settings will register your SauceLabs drivers into Capybara drivers
  Capybara.register_driver :used_driver do |app|
    Capybara::Selenium::Driver.new(app, @browser)
  end
  
else 
  #  default driver if not specified
  Capybara.register_driver :used_driver do |app|
    Capybara::Selenium::Driver.new(app, :browser => :firefox)
  end
end

# register the selected drivers as current driver used
Capybara.current_driver = :used_driver

```
In order to make the SauceLabs test drivers works, use SauceConnect to make it avalaible. to use SauceConnect, you can download and access the guide [here](https://wiki.saucelabs.com/display/DOCS/Sauce+Connect+Proxy)

Also, if you want to check out which driver is avalaible in SauceLabs service, You can access it's Platform Configurator in [here](https://wiki.saucelabs.com/display/DOCS/Platform+Configurator)

***Keep in mind*** that we should leave the `ENV['IDIFF_DRIVER']` as it is. You can add 
more test drivers by adding another `when` case in the code. After setting up the drivers, 
dont forget to require it in `spec_helper.rb` or `rails_helper.rb`. Example code is written below.

```rb
require_relative '../spec/supports/capybara_driver'
```

##### or

```rb
Dir[Rails.root.join('spec/supports/**/*.rb')].each { |f| require f }
```

The next thing that we should do is to configure `IntegrationDiff` in `spec_helper.rb`

```rb
require "integration-diff"

Rails.logger = Logger.new(STDOUT)

IntegrationDiff.configure do |config|
    # configure domain to which all images have to be uploaded.
    config.base_uri = "http://diff.codemancers.com"

    # configure project name to which images belong to.
    config.project_name = "Dummy"

    # configure api_key required to authorize api access
    config.api_key = ENV["IDIFF_API_KEY"]

    # configure js driver which is used for taking screenshots.
    config.javascript_driver = "poltergeist"

    # configure service to mock capturing and uploading screenshots
    config.enable_service = !!ENV["IDIFF_ENABLE"]

    # configure logger to log messages. optional.
    config.logger = Rails.logger
  end

RSpec.configure do |config|
  config.include IntegrationDiff::Dsl

  config.before(:suite) do
    IntegrationDiff.rerun ENV['IDIFF_RUN_ID'].to_i
  end

  config.after(:suite) do 
    IntegrationDiff.upload_run 
  end
  
end

```

`rerun` and `upload_run` are needed to wrap multiple test runs with only one 
report and one run id. Just leave `ENV['IDIFF_RUN_ID']` as it is as we need it 
to identify current run id.

And the last thing to do is to create a rake task in `lib/task/`. Here, I have 
`idiff.rake` in `lib/task/idiff.rake` that contains the code below.

```rb
array_of_driver = [:firefox, :saucelabs]

task :config_idiff do
  Rails.logger = Logger.new(STDOUT)

  IntegrationDiff.configure do |config|
      # configure domain to which all images have to be uploaded.
      config.base_uri = "http://diff.codemancers.com"

      # configure project name to which images belong to.
      config.project_name = "DummyStore"

      # configure api_key required to authorize api access
      config.api_key = ENV["IDIFF_API_KEY"]

      # configure js driver which is used for taking screenshots.
      config.javascript_driver = "poltergeist"

      # configure service to mock capturing and uploading screenshots
      config.enable_service = !!ENV["IDIFF_ENABLE"]

      # configure logger to log messages. optional.
      config.logger = Rails.logger
    end
end


task :idiff_bundle => [:config_idiff] do

  include IntegrationDiff::Dsl

  # Specify files path where the spec belongs to
  path = "spec/features/page_renders_spec.rb"
  
  # Execute rake task
  IntegrationDiff.start_run
  array_of_driver.each do |driver|
      `IDIFF_RUN_ID=#{IntegrationDiff.get_run_id} IDIFF_DRIVER=#{driver.to_s} rspec #{path}`
    end
  IntegrationDiff.wrap_run

end

```

The rake task `idiff_bundle` will execute the `rspec` command according to how many drivers 
registered in `array_of_driver`. `array_of_driver` contains all the driver you want to use
in the test. ***Keep in mind*** that the drivers listed in `array_of_driver` must be registered 
first in `spec/supports/capybara_driver.rb`.

***IMPORTANT***, environment variables `IDIFF_RUN_ID` and `IDIFF_DRIVER` must be listed in the command. You can also add any environment variable 
that you want in the backticks command.

After all the settings, to execute multiple runs. Just use `rake` to execute it. For example 
from the code presented. I execute this command to run the code above.

```rb
rake idiff_bundle
```


### Slack Notification

To configure Slack Notification, simply add 3 more setup variables in `IntegrationDiff.configure`. That is `project_id`, `slack_webhook_address`, and `slack_channel_name`  .Example code are presented below. 

```rb
    IntegrationDiff.configure do |config|
      # configure domain to which all images have to be uploaded.
      config.base_uri = "http://diff.codemancers.com"

      # configure project name to which images belong to.
      config.project_name = "DummyStore"

      # configure api_key required to authorize api access
      config.api_key = ENV["IDIFF_API_KEY"]

      # configure js driver which is used for taking screenshots.
      config.javascript_driver = "poltergeist"

      # configure service to mock capturing and uploading screenshots
      config.enable_service = !!ENV["IDIFF_ENABLE"]

      # configure logger to log messages. optional.
      config.logger = Rails.logger

      # configure project id for slack notification (optional)
      config.project_id = '16'

      # configure slack webhook address for slack notification (optional)
      config.slack_webhook_address = 'https://hooks.slack.com/services/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'

      # configure slack channel for slack notification (optional)
      config.slack_channel_name = '#integration-diff-bot'
  end
```

This Slack Notification are using Incoming Webhook services. For more information check the link over [here](https://api.slack.com/incoming-webhooks). After integration using Incoming Webhook, you can insert your own Slack Webhook address in `config.slack_webhook_address` in the code.

You can also set the channel where you want the message to be delivered. If not declared, the default value for `slack_channel_name` will be `#random`.

`project_id` are obtained from your project page in IntegrationDiff. for example, I'm currently accessing my project page. The browser provided the link below.

```
http://diff.codemancers.com/projects/16/runs
```

The number `16` would be the id of my project. And this id have to be instantiated in config in order to enable Slack Notification.