module ActiveRecord
  class Base
    delegate :transaction, :to=>"self.class"

    class << self
      def write_exception(error)
        user_backtrace = error.application_backtrace.reject{|i| i =~ %r{^\#\{RAILS_ROOT\}/vendor/}}
        trace = user_backtrace[0,2].join("\n")
        logger.error "%s: %s (%s)" % [error.class, error.message, trace]
      end
    end
  end
end

