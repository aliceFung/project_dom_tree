require_relative 'DOMReader.rb'

class NodeRenderer


  def initialize(tree)
    @tree = tree
  end

  def render(some_node)
    puts "Total nodes in tree: #{@tree.nodes}"
    puts "Current node:"
    puts "Type: #{some_node.type}" unless some_node.type.nil?
    puts "Parent: #{some_node.parent.type}" unless some_node.parent.nil?
    puts "Children: #{render_children(some_node)}"  unless some_node.children.nil?
    puts "Text: #{some_node.text.join(", ")}"  unless some_node.text.nil?
    puts "Class: #{some_node.class}"  unless some_node.class.nil?
    puts "ID: #{some_node.id}"  unless some_node.id.nil?
  end

  def render_children(some_node)
    string_arr =[]
    arr = some_node.children
    arr.each do |child|
      string_arr << child.type
    end
    string_arr.join(", ")
  end

  def count_children(some_node)

  end


end

tree = DOMReader.new
renderer = NodeRenderer.new(tree)
renderer.render(tree.root)