# frozen_string_literal: true

module RailsCom #:nodoc:
  mattr_accessor :config, default: ActiveSupport::OrderedOptions.new

  config.disable_debug = true
  config.intercept_not_found = true
  config.not_found_logger = ActiveSupport::Logger.new('log/not_found.log')
  config.github_hmac_key = 'must_change_this'
  config.default_error_message = '服务端发生错误'
  config.acme_url = 'https://acme-v02.api.letsencrypt.org/directory'  # 用于 SSL 证书自动签发服务
  config.default_admin_accounts = []
  config.debug = false
  config.debug_i18n = false
  config.default_return_path = '/board'
  config.enum_key = ->(o, attribute){ "#{o.i18n_scope}.enum.#{o.base_class.model_name.i18n_key}.#{attribute}" }
  config.ignore_exception = [
    'ActionController::UnknownFormat',
    'ActiveRecord::RecordNotFound'
  ]
  config.ignore_models = [
    'SolidQueue::Semaphore',
    'SolidQueue::Process',
    'SolidQueue::Pause',
    'SolidQueue::Job',
    'SolidQueue::ScheduledExecution',
    'SolidQueue::ReadyExecution',
    'SolidQueue::BlockedExecution',
    'SolidQueue::RecurringExecution',
    'SolidQueue::RecurringTask',
    'SolidCache::Entry',
    'Com::PgPublication',
    'Com::PgPublicationTable',
    'Com::PgSubscription',
    'Com::PgStatSubscription',
    'Com::PgReplicationSlot'
  ]
  config.override_prefixes = [
    'application'
  ]
  config.quiet_logs = []
end
