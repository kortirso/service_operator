# frozen_string_literal: true

RSpec.describe ServiceOperator do
  let(:operator) { Class.new.send(:include, described_class) }
  let(:configuration) { ServiceOperator::Configuration.new }

  before do
    allow(operator).to receive(:configuration).and_return(configuration)
  end

  it 'has a version number' do
    expect(ServiceOperator::VERSION).not_to be_nil
  end

  describe '.configure' do
    context 'without provided custom config' do
      it 'uses default configuration values', :aggregate_failures do
        expect(operator.configuration.call_method_name).to eq :call
        expect(operator.configuration.call_parameters_method_name).to be_nil
      end
    end

    context 'with provided custom config' do
      before do
        configuration.call_parameters_method_name = :call_parameters
      end

      it 'sets configuration values', :aggregate_failures do
        expect(operator.configuration.call_method_name).to eq :call
        expect(operator.configuration.call_parameters_method_name).to eq :call_parameters
      end
    end
  end
end
