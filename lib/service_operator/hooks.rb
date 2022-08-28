# frozen_string_literal: true

module ServiceOperator
  module Hooks
    def self.included(base)
      base.class_eval do
        extend ClassMethods
      end
    end

    module ClassMethods
      def around_hooks
        @around_hooks ||= []
      end

      # Examples
      #
      #   class MyOperator
      #     include ServiceOperator
      #
      #     around :use_transaction
      #
      #     around do |operator|
      #       puts 'started'
      #       operator.call
      #       puts 'finished'
      #     end
      #
      #     private
      #
      #     def use_transaction(operator)
      #       context.start_time = Time.now
      #       operator.call
      #       context.finish_time = Time.now
      #     end
      #   end
      #
      def around(name=nil, with: nil, **args, &block)
        around_hooks << Step.new(name: name, with: with, args: args, block: block)
      end
    end

    private

    def with_hooks(&block)
      run_before_steps
      run_around_hooks(&block)
      run_after_steps
    # rescue catches errors in before and after steps and stops execution
    rescue
    end

    # Internal: Run around step.
    def run_around_hooks(&block)
      self.class.around_hooks.reverse.inject(block) { |proc_chain, hook|
        proc { run_hook(hook, proc_chain) }
      }.call
    # rescue catches errors in around hooks and main steps and allow to run after steps
    rescue
    end

    def run_hook(hook, proc_chain)
      return hook.run(operator: self, context: context, block_variable: proc_chain) if hook.is_a?(Step)

      instance_exec(proc_chain, &hook)
    end
  end
end
