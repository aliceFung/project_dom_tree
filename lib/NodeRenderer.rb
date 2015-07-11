require_relative 'DOMReader.rb'

class NodeRenderer


  def initialize(tree)
    @tree = tree
  end

  def render(some_node = @tree.root)

    if some_node.nil?
      some_node = @tree.root
    end

    puts "Current node:"
    puts "Type: #{some_node.type}" unless some_node.type.nil?
    puts "Parent: #{some_node.parent.type}" unless some_node.parent.nil?
    puts "Children: #{render_children(some_node)}"  unless some_node.children.nil?
    puts "Text: #{some_node.text.join(", ")}"  unless some_node.text.nil?
    puts "Class(es): #{some_node.classes}"  unless some_node.class.nil?
    puts "ID: #{some_node.id}"  unless some_node.id.nil?

    count, type = count_children(some_node)

    puts "Total nodes below this node: #{count}"
    puts "Types of children below this node:"
    type.each do |key, value|
      puts "Tag: #{key} = #{value} ocurrences"
    end

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

    queue = [some_node]
    type = {}
    count = 0

    until queue.empty?
      current_node = queue.shift
      if type[current_node.type].nil?
        type[current_node.type] = 1
      else
        type[current_node.type] += 1
      end
      current_node.children.each { |child| queue << child }
      count += 1
    end

    return count, type

  end


end

tree = DOMReader.new
renderer = NodeRenderer.new(tree)
renderer.render(tree.root.children.first.children.last)

renderer.render(nil)


