# Loader class -> Load html document
#   -> Uses read so we get an array of every line
#   -> gsub \n and other breaks, run regex.match method
#   =>  vs readlines= array,
#    cons: cannot use .match on array
#    pros: easier to match tag, iterate thru to find first ending tag
# => parse tags by finding first corresponding closing tag =child
# Domreader ->
#   -> Builds tree on given html file
#   -> Tree
#     -> Root node: Whole document
#       -> Tag - :type, (i.e. div, p, h1)
#                :classes, (array)
#                :id,
#                --:name, <- can be ignored, alway nil for test doc
#                :text, (non-HMTL, but not in children tags)
#                :children, (array of tag nodes)
#                :parent, (node)
#   -> Parser: Analyzes the file and create the tags and children
# Renderer(tree)
#   => method(node)   ~to search, go through all children and count
#                     Keeps track of total nodes below a certain tag
#                     Counts how many tags we have of the same type
#                     Can tell us all possible info about a specific tag
#                     nil tag gives us statistics for whole doc
# Searcher(tree)
#   => search_by(attr, "name of attr") <= returns array of matches
#   => search_children(node)
#   => search_ancester(node)
# data structure for tree: struct (.methods) vs. hash (child org.?)

Tag = Struct.new(:type, :classes, :id, :name, :text, :children, :parent)

class DOMReader


  def initialize
    # @parser = Parser.new
    file = load_file
    # root_node(file)
    # @node
  end

  def load_file
    file = File.open("test.html", "r")
    string = file.read
    p string
  end

  def root_node(file)
    document = Tag.new(nil, nil, nil, nil, nil, [], nil)
  end

  def build_child(parent_node)
    parent_node.text

  end

  def build_tree

  end

end

class NodeRenderer

end

class TreeSearcher

end