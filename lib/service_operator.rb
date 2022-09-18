# frozen_string_literal: true

require 'service_operator/version'
require 'service_operator/configuration'
require 'service_operator/helpers'

module ServiceOperator
  extend self

  def configuration
    @configuration ||= Configuration.new
  end

  # Examples
  #
  #   ServiceOperator.configure do |config|
  #     config.call_parameters_method_name = :call_parameters
  #     config.failure_method_name = :failure?
  #   end
  #
  def configure
    yield(configuration)
  end

  # Public: Default per thread service_operator instance if configured.
  # Returns ServiceOperator::Configuration instance.
  def instance
    Thread.current[:service_operator_configuration] ||= configuration
  end
end
