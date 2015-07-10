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
# Edge cases:
#              nested tags -> We will set up a counter that starts at 0 for the beginning of the tag and if we find a tag of the same type we add to the counter, subtract when we find a closing tag, and actually "find" the closing tag when we find a closing tag and the counter is 0

Tag = Struct.new(:type, :classes, :id, :name, :text, :children, :parent)

class DOMReader


  def initialize
    # @parser = Parser.new
    file = load_file
    # root_node(file)
    # @node
  end

  def parent_finder(data)

    (0...data.length).each do |idx|

      if data[idx].is_tag?
        index = find_matching_tag(idx)
        data_extractor(data[idx..index])
      end
    end
    #

    #returns all the data inside two tags

  end

  def find_matching_tag(text, index)
    counter = 0
    tag = text[index]
    closing_tag = "</#{tag}>"
    (index...(text.length)).each do |i|
      # if tag == tag
      #  counter += 1
      # if tag == closing_tag && counter != 0
      #  counter -= 1
      #if tag == closing_tag && counter = 0
      #   closing_tag_index = i
      #   break
    end
    closing_tag_index
  end

  def data_extractor(data)

    #if not a tag << Tag.text
    #if it's a tag - skip from tag to closing matching tag
    #keep going for rest of data...
    data.each_with_index do |element, index|

      if element.is_tag?
        find_matching_tag(index)
        #data_extractor()
      else
        #Tag.text << element
      end

    end




  end

  def load_file
    file = File.open("test.html", "r")
    @doc = file.readlines
    @doc.map! { |item| item.strip }
  end

  def root_node(file)
    document = Tag.new(nil, nil, nil, nil, nil, [], nil)
  end

  def build_child(parent_node)

    #parser(@doc)

    #parent_node.text

  end

  def build_tree

  end

end

class NodeRenderer

end

class TreeSearcher

end