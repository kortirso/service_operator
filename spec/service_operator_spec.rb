# frozen_string_literal: true

RSpec.describe ServiceOperator do
  it 'has a version number' do
    expect(ServiceOperator::VERSION).not_to be_nil
  end
end
