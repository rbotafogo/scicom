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
=begin
def code(text)
  puts text.indent(4)
  eval(text, TOPLEVEL_BINDING)
end
=end

def code(script)

  # Let's capture the output of Renjin script in our own string.  We need to do that
  # using Renjin::Writer
  writer = R.set_std_out(String.new)
  
  puts script
  begin
    eval(script, TOPLEVEL_BINDING)
  rescue Exception => e
    puts e.message
  end

  R.set_default_std_out
  puts writer.string.indent(4)
  puts
  
end

def console(script)

  # Let's capture the output of Renjin script in our own string.  We need to do that
  # using Renjin::Writer
  writer = R.set_std_out(String.new)
  
  print("> #{script.strip.indent(0, '+ ')}")
  begin
    print("\n\n")
    eval(script, TOPLEVEL_BINDING)
  rescue Exception => e
    puts e.message
  end

  R.set_default_std_out
  puts writer.string.indent(4)
  puts
  
end

def comment_code(text)
  puts text.indent(4)
end

def ref(title, publication)
  "*#{title}*, #{publication}"
end

def list(text)
  puts text.indent(2)
end
