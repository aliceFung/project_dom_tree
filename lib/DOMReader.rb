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
    @root = Tag.new("Document", nil, [], [])
    #p processed_doc
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
    current_node = @root
    @processed_doc.each do |item|
      if is_tag?(item) && !closing_tag?(item)
        current_node = Tag.new(item, current_node, [], [])
      elsif closing_tag?(item)
        current_node = current_node.parent
      else
        current_node.text = item
      end
    end

  end

  def contains_children?(array)

    array.each do |element|
      return true if is_tag?(element) && !closing_tag?(element)
    end

    return false

  end


  # def build_child(string, parent_node)

  #   new_tag = parse_tag(string)
  #   new_tag.parent = parent_node
  #   new_tag
  # end

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

  def data_extractor(subset_data, parent_node)
    return if nil
    current_parent = parent_node
    puts "restarting data_extractor"
    start = nil
    subset_data.each_with_index do |element, index|
      if is_tag?(element) && !closing_tag?(element) && !subset_data.empty?
        puts "regex says #{element} is a tag *************"
        child_node = build_child(element,current_parent)
        puts "I am #{child_node}"
        end_tag_index = find_matching_tag(subset_data, index)
        puts "*****************"
        puts "#{end_tag_index} is end_tag_index"
        puts "------------------------------------------"
        puts "This is the data we are trying to get text from"
        p subset_data[(index+1)..(end_tag_index-1)]
        puts "------------------------------------------"
        if subset_data.length > 3
          text1, data2 = get_text(subset_data[(index+1)..(end_tag_index-1)])
        else
          text1 = subset_data[1]
          data2 = []

        end
      end
    end
  end


  def get_text(data) #and not text
    children_data = []
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
        puts "We've successfully added #{element} to child data"
      elsif !is_tag?(element) && counter != 1
        children_data << element
        puts "We've successfully added #{element} to child data"
      elsif counter == 1
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
    file = File.open("test.html", "r")
    doc = file.readlines
    doc.map! { |item| item.strip }
  end


end
# end

# class NodeRenderer

# end

# class TreeSearcher

# end