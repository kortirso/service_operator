# frozen_string_literal: true

module ServiceOperator
  module Steps
    def self.included(base)
      base.class_eval do
        extend ClassMethods
      end
    end

    module ClassMethods
      def before_steps
        @before_steps ||= []
      end

      def steps
        @steps ||= []
      end

      def after_steps
        @after_steps ||= []
      end

      # Examples
      #
      #   class MyOperator
      #     include ServiceOperator
      #
      #     before :set_start_time
      #     before :initial, with: SomeService
      #
      #     before do
      #       puts 'started'
      #     end
      #
      #     private
      #
      #     def set_start_time
      #       context.start_time = Time.now
      #     end
      #   end
      #
      def before(name=nil, with: nil, **args, &block)
        before_steps << Step.new(name: name, with: with, args: args, block: block)
      end

      # Examples
      #
      #   class MyOperator
      #     include ServiceOperator
      #
      #     step :set_initiated
      #     step :perform_work, with: AnotherService
      #
      #     step do
      #       puts 'going to finish'
      #     end
      #
      #     private
      #
      #     def set_initiated
      #       context.initiated = true
      #     end
      #   end
      #
      def step(name=nil, with: nil, **args, &block)
        steps << Step.new(name: name, with: with, args: args, block: block)
      end

      # Examples
      #
      #   class MyOperator
      #     include ServiceOperator
      #
      #     after :set_finish_time
      #     after :finishing, with: SomeService
      #
      #     after do
      #       puts 'finished'
      #     end
      #
      #     private
      #
      #     def set_finish_time
      #       context.finish_time = Time.now
      #     end
      #   end
      #
      def after(name=nil, with: nil, **args, &block)
        after_steps << Step.new(name: name, with: with, args: args, block: block)
      end
    end

    private

    # Internal: Run before steps.
    def run_before_steps
      run_steps(self.class.before_steps)
    end

    # Internal: Run after steps.
    def run_after_steps
      run_steps(self.class.after_steps)
    end

    # Internal: Run a colection of steps.
    def run_steps(steps)
      steps.each { |step| step.run(operator: self, context: context) }
    end
  end
end
