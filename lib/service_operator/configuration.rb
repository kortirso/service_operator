# frozen_string_literal: true

module ServiceOperator
  class Configuration
    attr_accessor :call_method_name, :call_parameters_method_name, :failure_method_name

    def initialize
      # Operator tries to run this method on step's service defined by `with` argument.
      @call_method_name = :call

      # Operator tries to run this method on step's service for fetching arguments list.
      @call_parameters_method_name = :call

      # Operator tries to run this method on step's service for checking failure status.
      @failure_method_name = nil
    end
  end
end
