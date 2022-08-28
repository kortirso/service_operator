# frozen_string_literal: true

require 'ostruct'

# rubocop: disable Style/OpenStructUse
module ServiceOperator
  Failure = Class.new(StandardError)

  class Context < OpenStruct
    def self.build(args={})
      context = new(args)
      context.failure = false
      context
    end

    # Public: Validate the ServiceOperator::Context.
    # If any required param is missed in context then it fails context
    def validate(required_params: [])
      fail if required_params.any?(&:nil?)
    end

    # Public: Fail the ServiceOperator::Context.
    # Failing a context raises an error that rollback all changes at transaction steps.
    # The context is also flagged as having failed.
    def fail
      self.failure = true
      raise Failure
    end

    def success?
      !failure
    end

    def failure?
      failure
    end
  end
end
# rubocop: enable Style/OpenStructUse
