require 'rubytree'
require 'pry'
module Peruse
  class Tree < Tree::TreeNode
    def index(level = 0)
      return {level => name} unless has_children?
      [{level => name}, children.flat_map { |child| child.index(level + 1) }]
    end

    def plaintext
      "#{print_tree}\n#{print_content}"
    end

    def gemname
      root.name
    end

    def html
      renderer = ERB.new(html_template)
      puts renderer.result(binding)
    end

    def html_template
      <<HTML
<h1><%= gemname %> Sourcecode</h1>
<h2>Index</h2>
<ul>
<% index.flatten.each do |k| %>
<li>
<%= '<ul><li>' * k.first.first %>
<%= k.first.last %>
<%= '</li></ul>' * k.first.first %>
</li>
<% end %>
</ul>
HTML
    end

    def print_tree(level = 0)
      str = ''
      if is_root?
        str += "*"
      else
        str +=  "|" unless parent.is_last_sibling?
        str += (' ' * (level - 1) * 4)
        str += (is_last_sibling? ? "+" : "|")
        str +=  "---"
        str += (has_children? ? "+" : ">")
      end
      binding.pry
      str + children { |child| child.print_tree(level + 1) if child }
    end

    def print_content
      str = ''
      if content
        str += ">>> #{content}"
        str += File.read(content)
      end

      str + children { |child| child.print_content if child }
    end
  end
end
