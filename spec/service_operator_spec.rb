# frozen_string_literal: true

RSpec.describe ServiceOperator do
  let(:operator) { Class.new.send(:include, described_class) }

  it 'has a version number' do
    expect(ServiceOperator::VERSION).not_to be_nil
  end

  describe '.configure' do
    context 'without provided custom config' do
      it 'uses default configuration values', :aggregate_failures do
        expect(operator.configuration.call_method_name).to eq :call
        expect(operator.configuration.call_parameters_method_name).to eq :call
      end
    end

    context 'with provided custom config' do
      it 'sets configuration values', :aggregate_failures do
        operator.configure do |config|
          config.call_parameters_method_name = :call_parameters
        end

        expect(operator.configuration.call_method_name).to eq :call
        expect(operator.configuration.call_parameters_method_name).to eq :call_parameters
      end
    end
  end

  describe '.step' do
    let(:step1) { :step1 }
    let(:step2) { :step2 }

    it 'sets steps' do
      expect {
        operator.step(step1)
        operator.step(step2)
      }.to change(operator, :steps)
        .from([])
        .to(
          [
            ServiceOperator::Step.new(name: step1, service: nil, args: {}),
            ServiceOperator::Step.new(name: step2, service: nil, args: {})
          ]
        )
    end
  end
end
