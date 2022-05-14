#!/usr/bin/env ruby
require "yaml"
require "optparse"
require "fileutils"

OUTPUT_DIR = "./output"

class Page
  def initialize(name, path)
    @name = name
    @path = path
  end
  def name
    @name
  end
  def path 
    @path
  end
  def output_html
    output = ""
    YAML.load_stream(File.read(@path)) do |doc|
      unless doc == nil
        doc.map {|k, v|
          output += build_html_element(k, v)
        }
      end
    end
    return output
  end
  def build_html_element(type, content)
    case type
    when "header-1"
      "<h1>#{content}</h1>"
    when "header-2"
      "<h2>#{content}</h2>"
    when "text"
      "<p>#{content}</p>"
    end
  end
end 

class Menu
  @@items = Array.new
  def intialize()
    @@items << self
  end
  def items
    @@items
  end
  def output_html
    output = "<ul>"
    items.map {|i|
      output = output + i.output_html
    }
    output = output + "</ul>"
    return output
  end
end

class MenuItem
  def initialize(text, link)
    @text = text
    @link = link
  end
  def text
    @text
  end
  def link
    @link
  end
  def output_html
    page_name = "#{@link.slice(0..(@link.index('.')))}html"
    return "<li><a href=#{page_name}>#{@text}</a></li>"
  end
end

class Site
  def initialize(pages, menu)
    @pages = pages
    @menu = menu
  end
  def generate
=begin
TODO: Go through each page and add in the menu at the beginning.
Also, generate a file for each page.
=end
    for page in @pages do
      html = "<html>"
      html += @menu.output_html
      html += page.output_html
      html += "</html>"
      page_name = page.name.slice(0..(page.name.index('.')))
      File.open("#{OUTPUT_DIR}/#{page_name}html", "w") do |f|
        f.truncate(0)
        f.write(html)
      end
    end
  end
end

def build_site(menu_file, pages_dir)
  Dir.mkdir(OUTPUT_DIR) unless Dir.exist?(OUTPUT_DIR)
  
  menu = Menu.new
  menu_yaml = YAML.load_file(menu_file)
  menu_yaml = menu_yaml["menu"]
  menu_yaml.map {|k, v|
    menu.items.push(MenuItem.new(k, v))
  }

  pages = Array.new
  Dir.children(pages_dir).map { |d| 
    if File.extname(d).downcase == ".yaml"
      page = Page.new(d, "#{pages_dir}/#{d}")
      page.output_html
      pages.push (page)
    end
  }
  site = Site.new(pages, menu)
  site.generate
end

def main
  options = {}
  OptionParser.new do |opt|
    opt.on('--menu MENU_FILE') { |o| options[:m_file] = o }
    opt.on('--dir FILE_DIR') { |o| options[:file_d] = o }
  end.parse!
  build_site(options[:m_file], options[:file_d])
end

main
