require "peruse/version"
require 'tree'

$setup = -> {
  $root = $require_level = nil
  alias :orig_require :require
  def require(file)
    $require_level = if $require_level
                       $require_level[file] or $require_level << Tree::TreeNode.new(file)
                     else
                       Tree::TreeNode.new(file)
                     end
    $root ||= $require_level
    r = orig_require(file)
    $require_level = $require_level.parent || $root
    r
  end
}

$teardown = -> {
  alias :require :orig_require
}

module Peruse
  def self.peruse(gemname)
    $setup.call
    require gemname
    $teardown.call
    $require_level
  end
end
