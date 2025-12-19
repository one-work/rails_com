# RailsCom
Rails 通用基础库

## 功能
* examples: puma, configs etc.
* rails and ruby core extension;
* methods deal rails model/controller/routes etc.
* some helpers, for generator uuid based on time and more;

## Module
* Ruby core extension
* Rails meta information: Controller/Model/Routes
* Rails core extension
  - ActiveStorage sync with url
  - ActiveStorage copy to mirror
* Utils
  - UidHelper
  - TimeHelper
  - Jobber
  - IpHelper
* 支持通过 ACME 自动申请及更新 SSL 证书
  
### Locals support

```erb
<%= render 'shared/locales' %>
```

## 支持 enum
```yaml
# zh.yml
activerecord:
  enum:
    notification:
      receiver_type:
        User: 全体用户
        Member: 成员
```

```ruby
t.select :receiver_type, options_for_select(Notification.options_i18n(:receiver_type))
```

* Override 
```yaml
activerecord:
  enum:
    notification:
      receiver_type:
        User: 全体用户
        Member: # remain this blank
```

## 注意
* 仅支持 webpacker, 不再支持 sprockets

## License
The gem is available as open source under the terms of the [LGPL License](https://opensource.org/licenses/LGPL-3.0).
