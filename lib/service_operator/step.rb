# frozen_string_literal: true

module ServiceOperator
  Step = Struct.new(:name, :with, :args, :block, keyword_init: true) do
    def run(operator:, context:, block_variable: nil)
      @operator = operator
      @context = context

      return instance_exec(block_variable || @operator, &block) if block
      return perform_hook_step if with

      perform_method_step(block_variable)
    end

    private

    def perform_hook_step
      step_object = with.new
      step_object.call(step_parameters(step_object))
      context.fail if step_object.failure?
    end

    # Private: Find parameters names for step object's call.
    # Then generate hash with these parameters from context.
    # Then overwrite some of them from step's args.
    def step_parameters(step_object)
      step_object
        .call_parameters
        .map { |e| e[1] }
        .index_with({}) { |attr_name| @context[attr_name] }
        .merge(args) { |_, _, new_value| @operator.send(new_value) }
    end

    def perform_method_step(block_variable)
      block_variable ? @operator.send(name, block_variable) : @operator.send(name)
    end
  end
end
