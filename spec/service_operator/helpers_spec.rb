# frozen_string_literal: true

RSpec.describe ServiceOperator::Helpers do
  let(:operator) { Class.new.send(:include, described_class) }
  let(:configuration) { ServiceOperator::Configuration.new }

  before do
    allow(operator).to receive(:configuration).and_return(configuration)
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
