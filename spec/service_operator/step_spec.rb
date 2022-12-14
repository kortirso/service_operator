# frozen_string_literal: true

RSpec.describe ServiceOperator::Step do
  let(:operator) { Class.new.send(:include, ServiceOperator::Helpers) }
  let(:configuration) { ServiceOperator::Configuration.new }

  before do
    allow(operator).to receive(:configuration).and_return(configuration)
  end

  describe '.run' do
    context 'for method step' do
      let(:step) { described_class.new(name: :method_name) }

      before { allow(operator).to receive(:send) }

      context 'without proc variable' do
        it 'runs method of operator' do
          step.run(operator: operator)

          expect(operator).to have_received(:send).with(:method_name)
        end
      end

      context 'with proc variable' do
        let(:proc_value) { proc { [1, 2].map { |index| index + 1 } } }

        it 'runs method of operator with proc' do
          step.run(operator: operator, proc: proc_value)

          expect(operator).to have_received(:send).with(:method_name, proc_value)
        end
      end
    end

    context 'for service step' do
      let(:service_class) { double }
      let(:service_object) { double }
      let(:context) { ServiceOperator::Context.build({ week_id: 1 }) }
      let(:step) { described_class.new(service: service_class, args: {}) }
      let(:parameters_list_method) { double }
      let(:parameters_list) { [] }
      let(:call_result) { false }
      let(:step_run) { step.run(operator: operator) }

      before do
        allow(service_class).to receive(:new).and_return(service_object)
        allow(service_object).to receive(:public_send)
        allow(service_object).to receive(:public_send).with(call_parameters_method_name).and_return(parameters_list)
        allow(service_object).to receive(:method).with(call_method_name).and_return(parameters_list_method)
        allow(parameters_list_method).to receive(:parameters).and_return(parameters_list)
        allow(operator).to receive(:context).and_return(context)
        allow(context).to receive(:fail)
      end

      context 'for default configuration' do
        let(:call_method_name) { :call }
        let(:call_parameters_method_name) { nil }

        context 'with empty call method parameters' do
          let(:parameters_list) { [] }

          it 'calls service', :aggregate_failures do
            step_run

            expect(service_object).to have_received(:public_send).with(:call)
            expect(context).not_to have_received(:fail)
          end
        end

        context 'with existing call method parameters' do
          let(:parameters_list) { [%i[keyreq week_id]] }

          it 'calls service with parameters', :aggregate_failures do
            step_run

            expect(service_object).to have_received(:public_send).with(:call, week_id: 1)
            expect(context).not_to have_received(:fail)
          end
        end

        # rubocop: disable Lint/UnusedMethodArgument, Metrics/ParameterLists
        context 'with full list of existing method arguments' do
          def jumbo_method(req, opt=nil, *rest, week_id:, key: nil, **keyrest)
            'mocked method'
          end

          let(:step) { described_class.new(service: service_class, args: {}) }
          let(:context) { ServiceOperator::Context.build({ week_id: 1, req: 'required' }) }
          let(:parameters_list) { method(:jumbo_method).parameters }

          it 'calls service with parameters', :aggregate_failures do
            step_run

            expect(service_object).to(
              have_received(:public_send).with(
                :call,
                'required',
                nil,
                nil,
                week_id: 1,
                key: nil,
                keyrest: nil
              )
            )
            expect(context).not_to have_received(:fail)
          end
        end
      end
      # rubocop: enable Lint/UnusedMethodArgument, Metrics/ParameterLists

      context 'for custom configuration' do
        let(:call_method_name) { :just_call }
        let(:call_parameters_method_name) { :call_parameters }

        before do
          allow(service_object).to receive(:public_send).with(:failure?).and_return(call_result)

          configuration.call_method_name = call_method_name
          configuration.call_parameters_method_name = call_parameters_method_name
          configuration.failure_method_name = failure_method_name
        end

        context 'without failure method' do
          let(:failure_method_name) { nil }

          context 'with empty call method parameters' do
            let(:parameters_list) { [] }

            it 'calls service', :aggregate_failures do
              step_run

              expect(service_object).to have_received(:public_send).with(:just_call)
              expect(context).not_to have_received(:fail)
            end
          end

          context 'with existing call method parameters' do
            let(:parameters_list) { [%i[keyreq week_id]] }

            it 'calls service with parameters', :aggregate_failures do
              step_run

              expect(service_object).to have_received(:public_send).with(:call_parameters)
              expect(service_object).to have_received(:public_send).with(:just_call, week_id: 1)
              expect(context).not_to have_received(:fail)
            end
          end
        end

        context 'with failure method' do
          let(:failure_method_name) { :failure? }

          context 'with empty call method parameters' do
            let(:parameters_list) { [] }

            it 'calls service', :aggregate_failures do
              step_run

              expect(service_object).to have_received(:public_send).with(:just_call)
              expect(context).not_to have_received(:fail)
            end
          end

          context 'with existing call method parameters' do
            let(:parameters_list) { [%i[keyreq week_id]] }

            it 'calls service with parameters', :aggregate_failures do
              step_run

              expect(service_object).to have_received(:public_send).with(:call_parameters)
              expect(service_object).to have_received(:public_send).with(:just_call, week_id: 1)
              expect(context).not_to have_received(:fail)
            end
          end

          context 'with failure in step service' do
            let(:parameters_list) { [] }
            let(:call_result) { true }

            it 'calls service', :aggregate_failures do
              step_run

              expect(service_object).to have_received(:public_send).with(:just_call)
              expect(context).to have_received(:fail)
            end
          end
        end
      end
    end
  end
end
