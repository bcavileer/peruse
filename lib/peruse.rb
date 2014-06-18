require "peruse/version"
require 'tree'
require 'pry'

module Peruse
  class MyTree < Tree::TreeNode
    def print_tree(level = 0)
      if is_root?
        print "*"
      else
        print "|" unless parent.is_last_sibling?
        print(' ' * (level - 1) * 4)
        print(is_last_sibling? ? "+" : "|")
        print "---"
        print(has_children? ? "+" : ">")
      end

      puts " #{name} : #{content}"

      children { |child| child.print_tree(level + 1) if child }
      self
    end

    def print_content
      if content
        puts
        puts ">>> #{content}"
        puts File.read(content)
      end

      children { |child| child.print_content if child }
      self
    end
  end

  class Peruser
    def initialize(gemname, kernel = Kernel)
      @gemname = gemname
      @kernel = kernel
      @root = @require_level = MyTree.new(gemname)
    end

    attr_accessor :gemname, :require_level, :root, :current_name
    attr_reader :kernel

    def peruse
      record do
        require gemname
      end
    end

    def record
      set_recorder
      copy_original_kernel_require
      redefine_kernel_require
      yield
      restore_original_kernel_require
      root
    end

    private

    def set_recorder
      $require_recorder = self
    end

    def copy_original_kernel_require
      kernel.class_eval do
        alias :original_kernel_require :require
      end
    end

    def redefine_kernel_require
      kernel.class_eval do
        def require(name)
          $require_recorder.instance_eval do
            set_current_name(name)
            push_require_level unless current_level?
            set_file_name
            r = original_kernel_require(name)
            pop_require_level
            r
          end
        end
      end
    end

    def set_file_name
      nm = nil
      $:.each do |p|
        rbname = current_name + '.rb'
        if File.exists? File.join(p, rbname)
          nm = File.join(p, rbname)
          break
        end
      end
      require_level.content = nm
    end

    def set_current_name(name)
      self.current_name = name
    end

    def current_level?
      require_level.name == current_name
    end

    def push_require_level
      self.require_level = existing_child || new_child
    end

    def existing_child
      require_level[current_name]
    end

    def new_child
      require_level << MyTree.new(current_name)
    end

    def pop_require_level
      self.require_level = require_level.parent || root
    end

    def restore_original_kernel_require
      kernel.class_eval do
        alias :require :original_kernel_require
      end
    end
  end
end
