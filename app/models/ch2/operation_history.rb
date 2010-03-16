class Ch2::OperationHistory < ActiveRecord::Base
  set_table_name :ch2_operation_histories
  class << self
    def execute(*args)
      options = args.optionize(:arg, :remote_ip)
      options[:arg]  = execute_arg(options[:arg])
      options[:type] = execute_type(options[:type])
      create!(options)
    end

    private
      def execute_arg(arg)
        arg
      end

      def execute_type(type)
        type || name.demodulize
      end
  end
end
