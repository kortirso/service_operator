# frozen_string_literal: true

require_relative 'service_operator/version'
require_relative 'service_operator/steps'
require_relative 'service_operator/step'
require_relative 'service_operator/hooks'
require_relative 'service_operator/context'
require_relative 'service_operator/configuration'

module ServiceOperator
  def self.included(base)
    base.class_eval do
      extend ClassMethods
      include Steps
      include Hooks

      attr_reader :configuration
      attr_reader :context
    end
  end

  module ClassMethods
    def configuration
      @configuration ||= Configuration.new
    end

    # Examples
    #
    #   class MyOperator
    #     include ServiceOperator
    #
    #     configure do |config|
    #       config.call_method_name = :call
    #       config.call_parameters_method_name = :call
    #     end
    #   end
    #
    def configure
      yield(configuration)
    end

    def required_params
      @required_params ||= []
    end

    # Examples
    #
    #   class MyOperator
    #     include ServiceOperator
    #
    #     required_context :week
    #   end
    #
    def required_context(*args)
      @required_params = args.flatten
    end

    def call(args={})
      new(**args).call
    end
  end

  def initialize(args={})
    @context = Context.build(args)
    @context.validate(required_params: self.class.required_params)
  end

  def call
    with_hooks { run_steps(self.class.steps) }
    context
  # rescue catches errors in before and after steps and stops execution
  rescue StandardError
    context
  end
end
