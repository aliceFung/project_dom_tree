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
# Captures op, closing tags, and everything inside: <[^<>]*>[^<>]*<\/[^<>]*>
# Finds an html tag: <[^<>]*>

Tag = Struct.new(:type, :classes, :id, :name, :text, :children, :parent)

class DOMReader

  TAG_RGX = /<[^<>]*>/
  CLASSES_R = /class\s*=\s*'([\w\s]*)'/
  TAG_TYPE_R = /<(\w*)\b/
  ID_R = /id\s*=\s*'([\w\s]*)'/
  NAME_R = /name\s*=\s*'([\w\s]*)'/

  def initialize
    # @parser = Parser.new
    file = load_file
    @processed_doc = process_doc(file) #<=rename
    @root = create_root_node
    build_child(@root)
  end

  def process_doc(file)
    processed_doc = file.map do |element|
      #regex? check for (info, tag, info, tag, info)< method
      #puts composite?(element)
      if composite?(element)
        element = tag_splitter(element)
      else
        element
      end
    end
    processed_doc.flatten!
    processed_doc -= [""]
    #puts @processed_doc
    #final processed document!!!! YAY!
  end

  def composite?(string)
    match = string.match(TAG_RGX).to_s

    if match.length == 0
      #No matches, string is text only
      return false
    elsif match == string
      # string is tag only
      return false
    else
      # string is composite
      return true
    end

    #match.length != 0 && match != string

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
    match = element.match(TAG_RGX).to_s
    return element if match.length == 0 || match == element
    arr = element.partition(match)
    arr.map! do |string|
      if composite?(string)
        tag_splitter(string)
      else
        string
      end
    end
    arr
  end

  def is_tag?(string)
    #use Regex?!?! to find < and > for tag identification
    string.match(TAG_RGX).is_a?(MatchData)
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

  def parse_tag(string, parent)
    t = Tag.new(nil, nil, nil, nil, nil, [], parent)
    tag = string.match(TAG_TYPE_R).captures.to_s #returns an array
    t.type = tag[0]
    str_class = string.match(CLASSES_R).captures #already an array
    t.classes = str_class.join.split(" ")
    t.id = string.match(ID_R).captures[0]
    t.name = string.match(NAME_R).captures[0]
    t
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
    doc = file.readlines
    doc.map! { |item| item.strip }
  end

  def create_root_node
    Tag.new("Document", nil, 0, nil, nil, [], nil)
    #creates root node w/ child of entire document
    #calls on node_creater w/ docdata & parent = root_node
  end

  def build_child(parent_node)

    #parser(@doc)

    #parent_node.text

  end


end

DOMReader.new

class NodeRenderer

end

class TreeSearcher

end