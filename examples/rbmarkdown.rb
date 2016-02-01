require 'indentation'

class Markdown

  def get_binding
    return binding()
  end
  
end

$mk = Markdown.new

def title(text)
  print "# #{text}\n\n"
end

def author(text)
  print "Author: #{text}\n\n"
end

def chapter(text)
  print "# #{text}\n\n"
end

def section(text)
  print "## #{text}\n\n"
end

def subsection(text)
  print "### #{text}\n\n"
end

def subsubsection(text)
  print "#### #{text}\n\n"
end

def paragraph(text)
  puts text
end

def subparagraph(text)
  puts text
end

def body(text)
  puts "#{text}"
end

def code(text)
  puts text.indent(4)
  # eval(text, $mk.get_binding)
  eval(text, TOPLEVEL_BINDING)
end

def console(script)
  puts("    > #{script}\n")
  print("    ")
  eval(script, TOPLEVEL_BINDING)
  puts 
end

def comment_code(text)
  puts text.indent(4)
end

def ref(title, publication)
  "*#{title}*, #{publication}"
end
