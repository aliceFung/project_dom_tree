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

Tag = Struct.new(:type, :parent, :children, :text, :classes, :id, :name)

class DOMReader

  attr_reader :root, :nodes

  TAG_RGX = /<[^<>]*?>/
  CLASSES_R = /class\s*=\s*'([\w\s]*)'/
  TAG_TYPE_R = /<([\w]+).*?>/
  ID_R = /id\s*=\s*'([\w\s]*)'/
  NAME_R = /name\s*=\s*'([\w\s]*)'/
  CLOSING_TAG_RGX = /<\/[^<>]*?>/

  def initialize
    file = load_file
    @processed_doc = process_doc(file)
    @root = Tag.new("Document", nil, [], [])
    @nodes = 1
    build_tree
  end

  def process_doc(file)
    processed_doc = file.map do |element|
      if composite?(element)
        element = tag_splitter(element)
      else
        element
      end
    end
    processed_doc.flatten!
    processed_doc -= ["", "<!doctype html>"]
  end

  def composite?(string)
    match = string.match(TAG_RGX).to_s
    !(match.length == 0) && !(match == string)
  end


  def build_tree
    current_node = @root
    @processed_doc.each do |item|
      if item.include?("<") && !item.include?("</")
        tag_classes = parse_classes(item)
        tag_name = parse_name(item)
        tag_id = parse_id(item)
        new_node = Tag.new(item, current_node, [], [], tag_classes, tag_id, tag_name)
        @nodes +=1
        current_node.children << new_node
        current_node = new_node
        puts "new node"
      elsif item.include?("</")
        current_node = current_node.parent
      else
        current_node.text = item
      end
    end
  end


  def parse_tag_type(string)
    match = string.match(TAG_TYPE_R)
    match.captures[0] unless match.nil?
  end

  def parse_classes(string)
    str_class = string.match(CLASSES_R)#already an array
    t.classes = str_class.captures.join.split(" ") unless str_class.nil?
  end

  def parse_name(string)
    str_name = string.match(NAME_R)
    t.name = str_name.captures[0] unless str_name.nil?
  end

  def parse_id(string)
    str_id = string.match(ID_R)
    t.id = str_id.captures[0] unless str_id.nil?
  end

  def tag_splitter(element)
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

  def load_file
    file = File.open("test.html", "r")
    doc = file.readlines
    doc.map! { |item| item.strip }
  end

end


# class NodeRenderer

# end

# class TreeSearcher

# end