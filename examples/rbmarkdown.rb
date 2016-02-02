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
  print "#{text}\n\n"
end

def code(text)
  puts text.indent(4)
  eval(text, TOPLEVEL_BINDING)
end

def console(script)

  # Let's capture the output of Renjin script in our own string.  We need to do that
  # using Renjin::Writer
  writer = Renjin::Writer.new
  R.set_std_out(writer)
  
  puts("    > #{script}\n")
  print("    ")
  eval(script, TOPLEVEL_BINDING)

  puts writer.string.indent(4)
  puts
  
  R.set_default_std_out
  
end

def console_error(script)
  puts("    > #{script}\n")
  print("    ")
  begin
    eval(script, TOPLEVEL_BINDING)
  rescue Exception => e
    puts e.message
  end
  puts 
end

def comment_code(text)
  puts text.indent(4)
end

def ref(title, publication)
  "*#{title}*, #{publication}"
end
