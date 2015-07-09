# Loader class -> Load html document
#   -> Uses read so we get an array of every line
# Domreader ->
#   -> Builds tree on given html file
#   -> Tree
#     -> Root node: Whole document
#       -> Tag - :type,
#                :classes,
#                :id,
#                :name,
#                :text,
#                :children,
#                :parent
#   -> Parser: Analyzes the file and create the tags and children
# Renderer(tag)  Keeps track of total nodes below a certain tag
#                     Counts how many tags we have of the same type
#                     Can tell us all possible info about a specific tag
#                     nil tag gives us statistics for whole doc
# Searcher


class DOMReader

end

class NodeRenderer

end

class TreeSearcher

end