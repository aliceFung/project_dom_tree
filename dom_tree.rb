Tag = Struct.new(:type, :classes, :id, :name, :children, :parent)

=begin
notes:
file processed
create_root_node
build_tree(pnode = @root, data.empty?)
  =>break if data.empty?
  =>calls on data extractor(pnode, data )



data_extractor(pnode, data)
  =>calls on build_child to create node
  => adding text info
  => parent
  => returns a completed node
  => w/o children info

build_child => basic node: tag info

doc => get tag => update doc by removing

=end

