require 'spec_helper'

module Peruse
  describe Peruser do
    subject { described_class.new 'test_peruse1' }

    it 'has a version number' do
      expect(Peruse::VERSION).not_to be nil
    end

    it 'keeps count' do
      expect(subject.peruse.children.count).to be 1
    end

    it 'builds a tree' do
      expect(subject.peruse).to be_a Tree::TreeNode
    end
  end
end
