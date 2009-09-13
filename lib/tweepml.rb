# TweepML Ruby Implementation - http://tweepml.org/code/ruby
#
# Author::      Damon P. Cortesi (@dacort)
# License::     Apache License, Version 2.0
#
# TweepML is an XML format used to represent a list of Tweeps (Twitter users).
require 'rexml/document'
include REXML

class TweepML
  attr_accessor :title, :description, :link, :date_created, :date_modified, :contact_name, :contact_screen_name,
    :copyright, :generator, :generator_link, :error_code, :error_description, :tags, :tweep_list
  
  # Create a new TweepML representation.
  #
  # Optional parameter of a string to parse
  def initialize(source=nil)
    @tweep_list = TweepList.new
    parse(source) if source
  end
  
  # Set the title of the TweepML document.
  # Max length is 80 characters
  def title=(title)
    @title = title[0..79]
  end
  
  # Set the description of the TweepML document.
  # Max length is 250 characters
  def description=(desc) 
    @description = desc[0..249]
  end
  
  # Set the _contact_name_ of the TweepML document.
  # Max length is 50 characters
  def contact_name=(contact_name)
    @contact_name = contact_name.gsub("@","")[0..49]
  end
  
  # Set the _generator_ of the TweepML document.
  # Max length is 100 characters
  def generator=(generator)
    @generator = generator[0..99]
  end
  
  # Set the _generator_link_ of the TweepML document.
  # Max length is 100 characters
  def generator_link=(url)
    @generator_link = url[0..99]
  end
  
  # XML representation of the TweepML
  def to_xml
    doc = Document.new
    tml = doc.add_element 'tweepml', {'version' => '1.0'}
    
    # Add the header elements
    head = tml.add_element 'head'
    [:title, :description, :link, :date_created, :date_modified, :contact_name, :contact_screen_name,
    :copyright, :error_code, :error_description, :tags].each do |prop|
      unless self.send(prop).nil?
        t = head.add_element prop.to_s
        t.text = self.send(prop)
      end
    end
    
    head.add_element("generator").text = "TweepML Ruby Generator v0.1"
    head.add_element("generator_link").text = "http://github.com/dacort/tweepml"
    
    # Add the tweep_list element
    tweep_list = tml.add_element 'tweep_list'
    
    # Iterate through all tweeps/tweep_lists - should probably use nodes
    self.tweep_list.tweep_lists.each do|tl|
      tweep_list.add_element(tl.to_xml)
    end
    
    doc
  end
  
  private 
  
  # Parse the TweepML string _source_ into a Ruby data structure and return it.
  def parse(source)
    doc = Document.new(source)
    
    # Parse the head element of the TweepML source
    doc.elements.each("tweepml/head/*") do |element|
      (self.send "#{element.name}=", element.text) if self.respond_to?(element.name)
    end
    
    # Parse the first tweep_list element
    tl = self.tweep_list
    root_tl = doc.elements['tweepml/tweep_list']
    root_tl.attributes.each do |key,value|
      (tl.send "#{key}=", value) if tl.respond_to?(key)
    end
    parse_tweep_list(tl, doc.elements['tweepml/tweep_list'])
  end
  
  def parse_tweep(tweep_list, element)
    return if (element.attributes['id'].nil? and element.attributes['screen_name'].nil?)
    t = Tweep.new(element.attributes['screen_name'], element.attributes['id'],
      element.attributes['title'],element.attributes['tags'])

    tweep_list.add_tweep(t)
  end
  
  def parse_tweep_list(tweep_list, element)
    # Parse tweep lists
    element.elements.each("*") do |element|
      if element.name.downcase == "tweep"
        # Parse and add the tweep to the root element
        parse_tweep(tweep_list, element)
      elsif element.name.downcase == "tweep_list"
        # Create a new tweep list
        tl = TweepList.new
        element.attributes.each do |key,value|
          (tl.send "#{key}=", value) if tl.respond_to?(key)
        end
        tweep_list.add_tweep_list(tl)
        
        # Recursively parse the tweep list
        parse_tweep_list(tl, element)
      end
    end
    
  end
end

class TweepList
  attr_accessor :title, :tags
  
  def initialize(title=nil, tags=nil)
    @title = title[0..79] unless title.nil?
    @tags = tags
    
    @nodes = []
  end
  
  # Add a nested TweepList
  def add_tweep_list(tweep_list)
    @nodes.push(tweep_list)
  end
  
  # Add a new Tweep
  def add_tweep(tweep)
    @nodes.push(tweep) unless self.find_by_screen_name(tweep.screen_name)
  end
  
  # Find a tweep in this list by screen_name
  def find_by_screen_name(screen_name)
    @nodes.select{|t| t.is_a?Tweep and t.screen_name == screen_name}.first
  end
  
  # List all tweeps in this list
  def tweeps
    @nodes.select{|t| t.is_a?Tweep}
  end
  
  # List all TweepLists in this list
  def tweep_lists
    @nodes.select{|t| t.is_a?TweepList}
  end
  
  # XML representation of TweepList
  def to_xml
    tweep_list = Element.new 'tweep_list'
    tweep_list.add_attribute('title', @title) unless @title.nil?
    tweep_list.add_attribute('tags', @tags) unless @tags.nil?
    
    @nodes.each{|n| tweep_list.add_element(n.to_xml)}
    
    tweep_list
  end
end

class Tweep
  attr_accessor :id, :screen_name, :title, :tags
  
  # Create a new Tweep
  def initialize(screen_name, id=nil, title=nil, tags=nil)
    @id = id.to_i unless id.nil?
    @screen_name = screen_name
    @title = title[0..79] unless title.nil?
    @tags = tags
  end
  
  # Set the _id_ of the Tweep, enforcing numerals
  def id=(id)
    @id = id.to_i
  end
  
  # Set the _title_ of the Tweep.
  # Max length is 80
  def title=(title)
    @title = title[0..79]
  end
  
  # String representation of a Tweep
  def to_s
    @screen_name
  end
  
  # XML representation of a Tweep
  def to_xml
    tweep = Element.new 'tweep'
    [:id, :screen_name, :title, :tags].each do |prop|
      unless self.send(prop).nil?
        tweep.add_attribute(prop.to_s, "#{self.send(prop)}")
      end
    end
    
    tweep
  end
  
  # Find a tweep by screen_name
  def self.find_by_screen_name(screen_name)
    found = nil
    
    ObjectSpace.each_object(Tweep) { |o|
      found = o if o.screen_name == screen_name
    }
    found
  end
end

