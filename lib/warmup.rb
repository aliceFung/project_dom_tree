Tag = Struct.new(:type, :classes, :id, :name, :children, :parent)

class Parser

  CLASS_R = /class\s*=\s*'([\w\s]*)'/
  TAG_R = /<(\w*)\b/
  ID_R = /id\s*=\s*'([\w\s]*)'/
  NAME_R = /name\s*=\s*'([\w\s]*)'/

  def parse_tag(string)
    t = Tag.new
    tag = string.match(TAG_R).captures.to_s #returns an array
    t.type = tag[0]
    str_class = string.match(CLASS_R).captures #already an array
    t.classes = str_class.join.split(" ")
    t.id = string.match(ID_R).captures[0]
    t.name = string.match(NAME_R).captures[0]
    t
  end
#Tag = Struct.new(:type, :classes, :id, :name, :text, :children, :parent)
  def parse_html(string)
    t = Tag.new
    tag = string.match(TAG_R).captures.to_s #returns an array
    t.type = tag[0]
    str_class = string.match(CLASS_R).captures #already an array
    t.classes = str_class.join.split(" ")
    t.id = string.match(ID_R).captures[0]
    t.name = string.match(NAME_R).captures[0]
    t
  end


end