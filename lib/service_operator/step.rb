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

    def perform_method_step(proc)
      proc ? @operator.send(name, proc) : @operator.send(name)
    end

    def perform_service_step
      service_object = service.new

      service_object_call(service_object)
      validate_service_object_call_result(service_object)
    end

    def service_object_call(service_object)
      service_call_arguments = fetch_service_call_arguments(service_object)

      if service_call_arguments
        service_object.public_send(@operator.configuration.call_method_name, *service_call_arguments)
      else
        service_object.public_send(@operator.configuration.call_method_name)
      end
    end

    def validate_service_object_call_result(service_object)
      failure_method_name = @operator.configuration.failure_method_name
      @operator.context.fail if failure_method_name && service_object.public_send(failure_method_name)
    end

    # Private: Find parameters names for step object's call.
    # Then generate hash with these parameters from operator.context.
    # Then overwrite some of them from step's args.
    def fetch_service_call_arguments(service_object)
      parameters_list = fetch_parameters_list(service_object)
      return if parameters_list.nil? || parameters_list.empty?

      generate_argument_for_method_call(parameters_list)
    end

    def fetch_parameters_list(service_object)
      if @operator.configuration.call_parameters_method_name
        service_object
          .public_send(@operator.configuration.call_parameters_method_name)
      else
        service_object
          .method(@operator.configuration.call_method_name)
          .parameters
      end
    end

    def generate_argument_for_method_call(parameters_list, positional_arguments=[], keyword_arguments={})
      parameters_list.each { |type, name|
        case type
        when :req, :opt, :rest then positional_arguments << fetch_value(name)
        when :keyreq, :key, :keyrest then keyword_arguments[name] = fetch_value(name)
        end
      }

      [*positional_arguments, keyword_arguments]
    end

    def fetch_value(name)
      args[name] ? @operator.send(args[name]) : @operator.context[name]
    end
  end
end
