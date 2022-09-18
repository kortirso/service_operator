# frozen_string_literal: true

require_relative 'steps'
require_relative 'step'
require_relative 'hooks'
require_relative 'context'

module ServiceOperator
  module Helpers
    def self.included(base)
      base.class_eval do
        extend ClassMethods
        include Steps
        include Hooks

        attr_reader :context
      end
    end

    module ClassMethods
      def required_params
        @required_params ||= []
      end

      # Examples
      #
      #   class MyOperator
      #     include ServiceOperator::Helpers
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

    def configuration
      ServiceOperator.instance
    end
  end
end
