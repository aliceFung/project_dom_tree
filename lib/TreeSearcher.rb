require_relative "DOMReader.rb"

class TreeSearcher

  def initialize(tree)

    @tree = tree

  end

  def search_by(kind, name)

    queue = [@tree.root]
    results = []

    until queue.empty?
      current_node = queue.shift
      current_node.children.each { |child| queue << child }
      if !current_node.send(kind).nil? && current_node.send(kind).include?(name)
        results << current_node
      end
    end

    results.each do |node|
      puts "We found #{node.type} with #{kind.to_s} #{node.send(kind)}"
    end

    results

  end

end

tree = DOMReader.new

searcher = TreeSearcher.new(tree)
sidebars = searcher.search_by(:classes, "sidebar")
# sidebars.each { |node| renderer.render(node) }

# searcher.search_children(some_node, :id, "key-section")

# searcher.search_ancestors(some_node, :class, "wrapper")