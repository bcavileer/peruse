require 'spec_helper'

describe Peruse do
  it 'has a version number' do
    expect(Peruse::VERSION).not_to be nil
  end

  it 'keeps count' do
    expect(Peruse.peruse('test_peruse1').children.count).to be 1
  end

  it 'builds a tree' do
    expect(Peruse.peruse('test_peruse1')).to be_a Tree::TreeNode
  end
end
