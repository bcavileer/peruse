require "peruse/version"
require 'tree'
require 'pry'

module Peruse
  class Peruser
    def initialize(gemname, kernel = Kernel)
      @gemname = gemname
      @kernel = kernel
    end

    attr_accessor :gemname, :require_level, :root
    attr_reader :kernel

    def peruse
      record do
        require gemname
      end
    end

    def record
      set_recorder
      monkey_kernel do
        copy_original_kernel_require
        redefine_kernel_require
        yield
        restore_original_kernel_require
      end
      require_level
    end

    def restore_original_kernel_require
      kernel.class_eval do
        alias :require :orig_require
      end
    end

    def redefine_kernel_require
      kernel.class_eval do
        def require(file)
          $recorder.instance_eval do
            self.require_level = if require_level
                                   require_level[file] or require_level << Tree::TreeNode.new(file)
                                 else
                                   Tree::TreeNode.new(file)
                                 end
            self.root ||= require_level
            r = orig_require(file)
            self.require_level = require_level.parent || root
            r
          end
        end
      end
    end

    def copy_original_kernel_require
      kernel.class_eval do
        alias :orig_require :require
      end
    end

    def monkey_kernel
      kernel.class_eval do
        yield
      end
    end

    def set_recorder
      $recorder = self
    end
  end
end
