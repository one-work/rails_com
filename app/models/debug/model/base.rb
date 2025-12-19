module Debug
  module Model::Base
    extend ActiveSupport::Concern

    included do
      after_initialize do
        puts "  #{self.class} after_initialize \e[32m new_record: #{new_record?} \e[0m \e[33m destroyed: #{destroyed?} \e[0m"
        shared_puts
      end
      after_find do
        puts "  #{self.class} after_find \e[32m new_record: #{new_record?} \e[0m \e[33m destroyed: #{destroyed?} \e[0m"
        shared_puts
      end
      before_validation do
        puts "  #{self.class} before_validation \e[32m new_record: #{new_record?} \e[0m \e[33m destroyed: #{destroyed?} \e[0m"
        shared_puts
      end
      after_validation do
        puts "  #{self.class} after_validation \e[32m new_record: #{new_record?} \e[0m \e[33m destroyed: #{destroyed?} \e[0m"
        shared_puts
      end
      before_save do
        puts "  #{self.class} before_save \e[32m new_record: #{new_record?} \e[0m \e[33m destroyed: #{destroyed?} \e[0m"
        shared_puts
      end
      around_save :debug_around_save
      before_create do
        puts "  #{self.class} before_create \e[32m new_record: #{new_record?} \e[0m \e[33m destroyed: #{destroyed?} \e[0m"
        shared_puts
      end
      around_create :debug_around_create
      after_create do
        puts "  #{self.class} after_create \e[32m new_record: #{new_record?} \e[0m \e[33m destroyed: #{destroyed?} \e[0m"
        shared_puts
      end
      before_update do
        puts "  #{self.class} before_update \e[32m new_record: #{new_record?} \e[0m \e[33m destroyed: #{destroyed?} \e[0m"
        shared_puts
      end
      around_update :debug_around_update
      after_update do
        puts "  #{self.class} after_update \e[32m new_record: #{new_record?} \e[0m \e[33m destroyed: #{destroyed?} \e[0m"
        shared_puts
      end
      after_save do
        puts "  #{self.class} after_save \e[32m new_record: #{new_record?} \e[0m \e[33m destroyed: #{destroyed?} \e[0m"
        shared_puts
      end
      after_commit do
        puts "  #{self.class} after_commit \e[32m new_record: #{new_record?} \e[0m \e[33m destroyed: #{destroyed?} \e[0m"
        shared_puts
      end
      after_rollback do
        puts "  #{self.class} after_rollback \e[32m new_record: #{new_record?} \e[0m \e[33m destroyed: #{destroyed?} \e[0m"
        shared_puts
      end
      before_destroy do
        puts "  #{self.class} before_destroy \e[32m new_record: #{new_record?} \e[0m \e[33m destroyed: #{destroyed?} \e[0m"
        shared_puts
      end
      around_destroy :debug_around_destroy
      after_destroy do
        puts "  #{self.class} after_destroy \e[32m new_record: #{new_record?} \e[0m \e[33m destroyed: #{destroyed?} \e[0m"
        shared_puts
      end
    end

    def debug_around_save
      puts "  #{self.class} around_save before yield \e[32m new_record: #{new_record?} \e[0m \e[33m destroyed: #{destroyed?} \e[0m"
      shared_puts
      yield
      puts "  #{self.class} around_save after yield \e[32m new_record: #{new_record?} \e[0m \e[33m destroyed: #{destroyed?} \e[0m"
      shared_puts
    end

    def debug_around_create
      puts "  #{self.class} around_create before yield \e[32m new_record: #{new_record?} \e[0m \e[33m destroyed: #{destroyed?} \e[0m"
      shared_puts
      yield
      puts "  #{self.class} around_create after yield \e[32m new_record: #{new_record?} \e[0m \e[33m destroyed: #{destroyed?} \e[0m"
      shared_puts
    end

    def debug_around_update
      puts "  #{self.class} around_update before yield \e[32m new_record: #{new_record?} \e[0m \e[33m destroyed: #{destroyed?} \e[0m"
      shared_puts
      yield
      puts "  #{self.class} around_update after yield \e[32m new_record: #{new_record?} \e[0m \e[33m destroyed: #{destroyed?} \e[0m"
      shared_puts
    end

    def debug_around_destroy
      puts "  #{self.class} around_destroy before yield \e[32m new_record: #{new_record?} \e[0m \e[33m destroyed: #{destroyed?} \e[0m"
      shared_puts
      yield
      puts "  #{self.class} around_destroy after yield \e[32m new_record: #{new_record?} \e[0m \e[33m destroyed: #{destroyed?} \e[0m"
      shared_puts
    end

    def shared_puts
      puts "\e[35m  object_id: #{object_id}  \e[0m"
      puts "\e[35m  changes: #{changes}  \e[0m" if changes.present?
      puts "\e[35m  saved: #{saved_changes}  \e[0m" if saved_changes.present?
      puts "\e[35m  previous: #{previous_changes}  \e[0m" if previous_changes.present?
      puts "\e[35m  attachment: #{attachment_changes}  \e[0m" if attachment_changes.present?
      puts "\e[31m  #{'- ~ ' * 40}-  \e[0m"
    end

  end
end
