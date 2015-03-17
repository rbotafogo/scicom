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
    @properties = Hash.new
    super
  end
  
  #----------------------------------------------------------------------------------------
  # Machine starts in the metadata state.
  #----------------------------------------------------------------------------------------

  state_machine :state, initial: :metadata do

    event :read_value do
      transition :metadata => :reading
    end

    event :value_read do
      transition :reading => :metadata
    end

    before_transition :on => :value_read, :do => :set_value

  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------
  
  def set_value
    @properties[@name] = @text
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------
  
  def tag_start(name, value)
    @name = name
    read_value
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def tag_end(name)
    value_read
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
      raise "Unknown type #{type}"
    end

  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def http_download_uri(uri, filename)
    puts "Starting HTTP download for: " + uri.to_s
    http_object = Net::HTTP.new(uri.host, uri.port)
    http_object.use_ssl = true if uri.scheme == 'https'
    begin
      http_object.start do |http|
        request = Net::HTTP::Get.new uri.request_uri
        http.read_timeout = 500
        http.request request do |response|
          open filename, 'wb' do |io|
            response.read_body do |chunk|
              io.write chunk
            end
          end
        end
      end
    rescue Exception => e
      puts "=> Exception: '#{e}'. Skipping download."
      return
    end
    puts "Stored download as " + filename + "."
  end
  
  #----------------------------------------------------------------------------------------
  # Installs a new package
  #----------------------------------------------------------------------------------------

  def load_package(name)

    renjin_cran = 'http://nexus.bedatadriven.com/content/groups/public/org/renjin/cran/'
    package = renjin_cran + name
    spec = package + "/" + "maven-metadata.xml"
    # read the maven-metadata specification
    uri = URI(spec)

    # parse the maven-metadata file
    parse = ParseXML.new(Net::HTTP.get(uri))
    parse.add_observer(self)
    parse.start

    download_dir = package + '/' + @properties['latest']
    spec2 = download_dir + '/' + "maven-metadata.xml"

    # parse the second maven-metadata file
    uri = URI(spec2)
    # need to clear the properties.  If the file has multiple properties with the same
    # name, then only the last one will be kept.  This might be a problem, but for 
    # now this does not seem to matter... We are only interested in the 'value'
    # property that seems to always be the same for the 'pom' and 'jar' files.
    @properties.clear
    parse = ParseXML.new(Net::HTTP.get(uri))
    parse.add_observer(self)
    parse.start
    
    filename = '/' + name + '-' + @properties['value'] + ".jar"
    download_file = download_dir + filename
    target_file = SciCom.cran_dir + '/' + name + ".jar"

    uri = URI.parse(download_file)
    http_download_uri(uri, target_file)

  end

end
