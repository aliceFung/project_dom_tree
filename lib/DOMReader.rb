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
    process_doc(file) #<=rename
    root_node(file)
    # @node
  end

  def process_doc(file)
    file.each do |element|
      #regex? check for (info, tag, info, tag, info)< method
        # tagsplitter
      #
    end
    #final processed document!!!! YAY!
  end

  def check_info_tag_combo(string)
    #regex? check for (info, tag, info, tag, info)< method
    #    ^(.*?)<\w+>(.*?)<\/\w+>(.*?)$
    #<li>One header</li>
    #testing<span> here more words </span> end.
    #hello
  end

  #how to stop when no more tags
  def build_tree
    #makes nodes until entire document is done!
    #until node.children.nil?
    #go through processed doc; if tag, make node with children
    #should go through whole doc
  end

  def tag_splitter(element)
    #if element has >1 tag
    #EDGE CASES:
    #"<li>One header</li> <= split further?!?! (tag, info, tag)
    #"testing<span> here </span> end." (info, tag, info, tag, info)
  end

  def is_tag?(string)
    #use Regex?!?! to find < and > for tag identification

    #return true if match
  end


  def node_maker(data, parent_node)

    (0...data.length).each do |idx|

      if data[idx].is_tag? #separates text data and children
        index = find_matching_tag(idx)
        data_extractor(data[idx..index])
        #tag.text, and (tag.children= raw data)
        #break
      end
    end
    #other info for tag from parser
    #Tag.new(hash[type], hash[classes], hash...)
    #tag.parent = parent_node

    #?returns all the data inside two tags?

  end

  def parser(obj, idx_of_opening_tag)
    #parses tag information to put into node
    #assign to tag object hash[type]= , hash[classes]
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
        #children to be made << data(index..closing)
      else
        #Tag.text << element
      end

    end
    #returns text attr for node creation
    #list of children for this node


  end

  def load_file
    file = File.open("test.html", "r")
    @doc = file.readlines
    @doc.map! { |item| item.strip }
  end

  def root_node(file)
    document = Tag.new(nil, nil, nil, nil, nil, [], nil)
    #creates root node w/ child of entire document
    #calls on node_creater w/ docdata & parent = root_node
  end

  def build_child(parent_node)

    #parser(@doc)

    #parent_node.text

  end


end

class NodeRenderer

end

class TreeSearcher

end