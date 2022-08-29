# frozen_string_literal: true

module ServiceOperator
  Step = Struct.new(:name, :service, :args, :block, keyword_init: true) do
    def run(operator:, proc: nil)
      @operator = operator

      return instance_exec(proc || @operator, &block) if block
      return perform_service_step if service

      perform_method_step(proc)
    end

    private

    def perform_service_step
      step_object = service.new

      perform_step_object_call(step_object)
      check_step_object_failure(step_object)
    end

    def perform_step_object_call(step_object)
      step_object_parameters = step_parameters(step_object)

      if step_object_parameters
        step_object.public_send(@operator.configuration.call_method_name, step_object_parameters)
      else
        step_object.public_send(@operator.configuration.call_method_name)
      end
    end

    def check_step_object_failure(step_object)
      failure_method_name = @operator.configuration.failure_method_name
      @operator.context.fail if failure_method_name && step_object.public_send(failure_method_name)
    end

    # Private: Find parameters names for step object's call.
    # Then generate hash with these parameters from operator.context.
    # Then overwrite some of them from step's args.
    def step_parameters(step_object)
      parameters_list =
        step_object
        .method(@operator.configuration.call_parameters_method_name)
        .parameters
      return if parameters_list.empty?

      parameters_list
        .map { |e| e[1] }
        .each_with_object({}) { |attr_name, acc| acc[attr_name] = @operator.context[attr_name] }
        .merge(args) { |_, _, new_value| @operator.send(new_value) }
    end

    def perform_method_step(proc)
      proc ? @operator.send(name, proc) : @operator.send(name)
    end
  end
end
