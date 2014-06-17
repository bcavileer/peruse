require "peruse/version"
require 'tree'

$setup = lambda {
  $require_level = []
  alias :orig_require :require
  def require(file)
    puts "#{$require_level.join}#{file}"
    $require_level << "-"
    r = orig_require(file)
    $require_level.pop
    r
  end
}

module Peruse
  def self.peruse(gemname)
    $setup.call
    require gemname
  end
end
