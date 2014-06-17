require 'spec_helper'

describe Peruse do
  it 'has a version number' do
    expect(Peruse::VERSION).not_to be nil
  end

  it 'does something useful' do
    described_class.peruse('rake')
  end
end
