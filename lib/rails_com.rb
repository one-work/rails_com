# frozen_string_literal: true

require 'rails_com/config'
require 'rails_com/engine'

require 'rails_com/action_controller'
require 'rails_com/action_dispatch'
require 'rails_com/action_mailbox'
require 'rails_com/action_text'
require 'rails_com/action_view'
require 'rails_com/active_model'
require 'rails_com/active_record'
require 'rails_com/active_storage'

require 'rails_com/core'
require 'rails_com/env'
require 'rails_com/exports'
require 'rails_com/generators'
require 'rails_com/models'
require 'rails_com/quiet_logs'
require 'rails_com/routes'
require 'rails_com/type'  # 支持的 attribute type 扩展
require 'rails_com/utils'

# Rails extension
require 'generators/scaffold_generator'
require 'generators/jbuilder_generator' if defined?(Jbuilder)

# default_form, 需要位于 rails_com 的加载之后
require 'default_form/config'
require 'default_form/active_record/extend'
require 'default_form/override/action_view/helpers/tags/collection_check_boxes'
require 'default_form/override/action_view/helpers/tags/collection_radio_buttons'
require 'default_form/controller_helper'
require 'default_form/view_helper'

# active storage
require 'active_storage/service/disc_service'

# outside
require 'csv'
require 'ostruct'
require 'solid_queue'
require 'solid_cache'
require 'default_where'
require 'kaminari'
require 'positioning'
require 'turbo-rails'
require 'money-rails'
require 'bigdecimal'
require 'net/scp'
require 'sshkey'

require 'rails_com/money/formatter'
