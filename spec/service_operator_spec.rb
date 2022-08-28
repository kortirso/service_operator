# frozen_string_literal: true

RSpec.describe ServiceOperator do
  let(:operator) { Class.new.send(:include, described_class) }

  it 'has a version number' do
    expect(ServiceOperator::VERSION).not_to be_nil
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
            ServiceOperator::Step.new(name: step1, with: nil, args: {}),
            ServiceOperator::Step.new(name: step2, with: nil, args: {})
          ]
        )
    end
  end
end
