# RailsCom
Rails Common engine, with many sugars!

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'rails_com'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install rails_com
```
## Features
* examples: puma, configs etc.
* rails and ruby core extension;
* methods deal rails model/controller/routes etc.
* some helpers, for generator uuid based on time and more;

## Module
* Ruby core extension
* Rails meta informations: Conroller/Model/Routes
* Rails core extension
  - Activestorage sync with url
  - Activestorage copy to mirror
* Utils
  - UidHelper
  - TimeHelper
  - Jobber
  - IpHelper
  
### Locals support

```erb
<%= render 'shared/locales' %>
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [LGPL License](https://opensource.org/licenses/LGPL-3.0).