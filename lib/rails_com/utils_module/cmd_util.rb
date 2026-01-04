# frozen_string_literal: true

module CmdUtil
  extend self

  def exec(cmd)
    Open3.popen2e(cmd) do |_, output, thread|
      Rails.logger.info "\e[35m  #{cmd} (PID: #{thread.pid})  \e[0m"
      output.each_line do |line|
        Rails.logger.info "  #{line.chomp}"
      end
      puts "\n"
    end
  end

end