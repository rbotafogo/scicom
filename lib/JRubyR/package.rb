# -*- coding: utf-8 -*-

##########################################################################################
# @author Rodrigo Botafogo
#
# Copyright © 2013 Rodrigo Botafogo. All Rights Reserved. Permission to use, copy, modify, 
# and distribute this software and its documentation, without fee and without a signed 
# licensing agreement, is hereby granted, provided that the above copyright notice, this 
# paragraph and the following two paragraphs appear in all copies, modifications, and 
# distributions.
#
# IN NO EVENT SHALL RODRIGO BOTAFOGO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, 
# INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF 
# THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF RODRIGO BOTAFOGO HAS BEEN ADVISED OF THE 
# POSSIBILITY OF SUCH DAMAGE.
#
# RODRIGO BOTAFOGO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE 
# SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". 
# RODRIGO BOTAFOGO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, 
# OR MODIFICATIONS.
##########################################################################################

require 'net/http'
require 'state_machine'
require 'rexml/document'
require 'observer'

##########################################################################################
#
##########################################################################################

module MergeObservable
  include Observable

  alias_method :old_notify, :notify_observers

  def add_new_observer(observer)
    @new_observers ||= Array.new
    @new_observers << observer
  end

  def merge_observers
    @new_observers ||= Array.new
    @new_observers.each do |obs|
      self.add_observer(obs)
    end
    @new_observers = nil 
  end

  def notify_observers(*args)
    merge_observers
    old_notify(*args)
  end

end

##########################################################################################
#
##########################################################################################

class PackageManager

  ##########################################################################################
  # Class to parse the maven-metadata.xml file for package management
  ##########################################################################################
  
  class ParseXML
    include MergeObservable
    
    #----------------------------------------------------------------------------------------
    # Parse the input_file and send parsed events to the given state machine.  Results should
    # be stored in the output_dir
    #----------------------------------------------------------------------------------------
    
    def initialize(source)
      @source = source
    end
    
    #----------------------------------------------------------------------------------------
    # start parsing the file.  This class will receive the events and redirect them to 
    # listeners
    #----------------------------------------------------------------------------------------
    
    def start
      REXML::Document.parse_stream(@source, self)
    end
    
    #----------------------------------------------------------------------------------------
    # This method is necessary do ignore parsing events that are of no interest to our
    # parsing.
    #----------------------------------------------------------------------------------------
    
    def method_missing(*args)
      # p args
    end
    
    #----------------------------------------------------------------------------------------
    # Called when receiving a tag_start event
    #----------------------------------------------------------------------------------------
    
    def tag_start(name, attrs)
      changed
      notify_observers(:tag_start, name, attrs)
    end
    
    #----------------------------------------------------------------------------------------
    # Called when receiving a tag_end event
    #----------------------------------------------------------------------------------------
    
    def tag_end(name)
      changed
      notify_observers(:tag_end, name, nil)
    end
    
    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------
    
    def text(text)
      changed
      notify_observers(:new_text, text, nil)
    end
    
  end

  ##########################################################################################
  #
  ##########################################################################################

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def initialize
    super
  end
  
  #----------------------------------------------------------------------------------------
  # Machine starts in the metadata state.
  #----------------------------------------------------------------------------------------

  state_machine :state, initial: :metadata do

    event :latest do
      transition :metadata => :latest
    end

    event :end_latest do
      transition :latest => :metadata
    end

    before_transition :on => :end_latest,  :do => :get_latest

    event :version do
      transition :metadata => :version
    end

    event :end_version do
      transition :version => :metadata
    end

    before_transition :on => :end_version,  :do => :get_version

    event :lastUpdated do
      transition :metadata => :lastUpdated
    end

    event :end_lastUpdated do
      transition :lastUpdated => :metadata
    end

    before_transition :on => :end_lastUpdated,  :do => :get_lastUpdated

  end

  def get_latest
    @latest = @text
  end

  def get_version
    @version = @text
  end

  def get_lastUpdated
    @lastUpdated = @text
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------
  
  def tag_start(name, value)
    
    case name
    when "latest"
      latest
    when "version"
      version
    when "lastUpdated"
      lastUpdated
    end
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def tag_end(name)

    case name
    when "latest"
      end_latest
    when "version"
      end_version
    when "lastUpdated"
      end_lastUpdated
    end

  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def new_text(text)
    @text = text
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def update(type, name, attrs)
    
    case type
    when :tag_start
      tag_start(name, attrs)
    when :tag_end
      tag_end(name)
    when :new_text
      new_text(name)
    else
      p "ooops error"
    end

  end

  #----------------------------------------------------------------------------------------
  # Installs a new package
  #----------------------------------------------------------------------------------------

  def load_package(name)

    renjin_cran = 'http://nexus.bedatadriven.com/content/groups/public/org/renjin/cran/'
    spec = "maven-metadata.xml"
    uri = URI(renjin_cran + name + "/" + spec)

    # parse the maven-metadata file
    parse = ParseXML.new(Net::HTTP.get(uri))
    parse.add_observer(self)
    parse.start

    p "latest version is #{@latest}"
    p "version is #{@version}"
    p "last updated is #{@lastUpdated}"

=begin
require 'net/http'
# Must be somedomain.net instead of somedomain.net/, otherwise, it will throw exception.
Net::HTTP.start("somedomain.net") do |http|
    resp = http.get("/flv/sample/sample.flv")
    open("sample.flv", "wb") do |file|
        file.write(resp.body)
    end
end
puts "Done."
=end

  end

end
