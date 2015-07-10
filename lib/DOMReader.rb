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
  CLOSING_TAG_RGX = /<\/[^<>]*?>/

  def initialize
    # @parser = Parser.new
    file = load_file
    @processed_doc = process_doc(file) #<=rename
    @root = create_root_node
    build_tree(@root, @processed_doc)
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
    processed_doc -= ["", "<!doctype html>"]
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

  def build_tree(parent_node, doc)
    #break if doc.empty?
    #makes nodes until entire document is done!
    new_node = data_extractor(doc, parent_node)
    #updated_doc #???
    #build_tree(new_node, updated_doc)
    #until node.children.nil?
    #go through processed doc; if tag, make node with children
    #should go through whole doc
  end

  def data_extractor(subset_data, parent_node)
    return if subset_data.empty?
    #if not a tag << Tag.text
    #if it's a tag - skip from tag to closing matching tag
    #keep going for rest of data...
    current_parent = parent_node
    subset_data.each_with_index do |element, index|

      if is_tag?(element)
        child_node = build_child(element,current_parent)
        end_tag_index = find_matching_tag(subset_data, index)
        text1, data2 = get_text(subset_data[(index+1)..(end_tag_index-1)])
        child_node.text = text1
        #data_extractor()
        #children to be made << data(index..closing)
        current_parent = child_node
        subset_data = data2
      end

      data_extractor(subset_data, current_parent)
    end

    #build_tree(current_parent, updated_doc)

    #returns text attr for node creation
    #list of children for this node
  end


  def get_text(data) #and not text
    children_data=[]
    counter = 0
    text_results = []
    data.each do |element|
      if is_tag?(element)
        counter += 1
        children_data << element
      elsif !is_tag?(element) && counter !=0
        children_data << element
      elsif closing_tag?(element)
        counter -= 1
        children_data << element
      elsif counter == 0
        text_results << element
      end
    end

    return text_results, children_data

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



  def closing_tag?(string)
    string.match(CLOSING_TAG_RGX).is_a?(MatchData)
  end

  def parse_tag(string)
    t = Tag.new(nil, nil, nil, nil, nil, [], nil)
    tag = string.match(TAG_TYPE_R).captures.to_s #returns an array
    t.type = tag[0]

    str_class = string.match(CLASSES_R)#already an array
    t.classes = str_class.captures.join.split(" ") unless str_class.nil?
    str_id = string.match(ID_R)
    t.id = str_id.captures[0] unless str_id.nil?
    str_name = string.match(NAME_R)
    t.name = str_name.captures[0] unless str_name.nil?
    t
  end

  def find_matching_tag(text, index)
    counter = 0
    p text
    tag = text[index] #<html> => html
    str_tag = tag.match(TAG_TYPE_R).to_s[1..-1]
    p tag
    closing_tag = "</#{str_tag}>"
    closing_tag_index = nil
    ((index+1)...(text.length)).each do |i|
      if tag == text[i]
       counter += 1
       puts "tag = text[i]"
      elsif text[i] == closing_tag && counter != 0
       counter -= 1
       puts "tag = text[i] && counter !=0"
      elsif text[i] == closing_tag && counter == 0
        closing_tag_index = i
        puts "I'm the closing tag"
      end
    end
    closing_tag_index
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

  def build_child(string, parent_node)

    new_tag = parse_tag(string)
    new_tag.parent = parent_node
    #parent_node.text

  end


end
# end

# class NodeRenderer

# end

# class TreeSearcher

# end