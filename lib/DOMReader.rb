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
require 'pry-byebug'

Tag = Struct.new(:type, :classes, :id, :name, :text, :children, :parent)

class DOMReader

  attr_reader :root

  TAG_RGX = /<[^<>]*?>/
  CLASSES_R = /class\s*=\s*'([\w\s]*)'/
  TAG_TYPE_R = /<([\w]+).*?>/
  ID_R = /id\s*=\s*'([\w\s]*)'/
  NAME_R = /name\s*=\s*'([\w\s]*)'/
  CLOSING_TAG_RGX = /<\/[^<>]*?>/

  def initialize
    # @parser = Parser.new
    file = load_file
    @processed_doc = process_doc(file) #<=rename
    @root = create_root_node
    build_tree
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

  def build_tree
 #   binding.pry

    queue = [[@root, @processed_doc]]
    until queue.empty?
      info_to_build = queue.shift
      current_parent = info_to_build[0]
      doc = info_to_build[1]
      puts "This is the doc #{doc}______________"
      child = build_child(doc, current_parent)
      p child
      text_d, c_data = get_text(doc)
      unless child.is_a?(Tag)
        child.text = text_d
        child.parent = current_parent
        queue << [child, c_data] unless c_data.empty?
        end
      end
    end

  end

  def data_extractor(data) #get text
    data.each do |item|
      return item if is_tag?(item)
    end

  end


  def get_text(data) #and not text
    children_data=[]
    counter = 0
    text_results = []
    data.each do |element|
      if closing_tag?(element)
        counter -= 1
        children_data << element
        #puts "We've successfully added #{element} to child data"
      elsif !is_tag?(element) && counter !=0
        children_data << element
        #puts "We've successfully added #{element} to child data"
      elsif is_tag?(element)
        counter += 1
        children_data << element
        #puts "We've successfully added #{element} to child data"
      elsif counter == 0
        text_results << element
        #puts "**We've successfully added #{element} to text data**"
      end
    end

    return text_results, children_data[1..-2]

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
    string.match(TAG_RGX).is_a? (MatchData)
    #return true if match
  end



  def closing_tag?(string)
    string.match(CLOSING_TAG_RGX).is_a?(MatchData)
  end

  def parse_tag(string)
    return "string is not a tag" unless is_tag?(string)
    t = Tag.new(nil, nil, nil, nil, nil, [], nil)
    tag = string.match(TAG_TYPE_R).captures.to_s #returns an array
    t.type = tag

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
    #p text
    tag = text[index] #<html> => html
    str_tag = tag.match(TAG_TYPE_R).to_s[1..-1]
    p "#{tag} = tag----------------"
    closing_tag = "</#{str_tag}>"
    p "#{closing_tag} = closing tag ------------"
    closing_tag_index = nil
    ((index+1)...(text.length)).each do |i|
      if tag == text[i]
       counter += 1
       #puts "tag = text[i]"
      elsif text[i] == closing_tag && counter != 0
       counter -= 1
       #puts "tag = text[i] && counter !=0"
      elsif text[i] == closing_tag && counter == 0
        closing_tag_index = i
        #puts "I'm the closing tag"
      end
    end
    p closing_tag_index
    closing_tag_index
  end


  def load_file
    file = File.open("../test.html", "r")
    doc = file.readlines
    doc.map! { |item| item.strip }
  end

  def create_root_node
    Tag.new("Document", nil, 0, nil, nil, [], nil)
    #creates root node w/ child of entire document
    #calls on node_creater w/ docdata & parent = root_node
  end

  def build_child(doc_array, parent_node)
    unless is_tag?(doc_array[0])
      new_tag = parse_tag(doc_array[0])
      new_tag.parent = parent_node
      new_tag
    end
    #parent_node.text

  end


end
# end

# class NodeRenderer

# end

# class TreeSearcher

# end