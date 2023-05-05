require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"

before do 
  @contents = File.readlines("data/toc.txt")
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"

  erb :home
end

get "/chapters/:number" do
  number = params[:number].to_i

  redirect "/" unless (1..@contents.size).cover? number # These two cases aren't considered unknown paths, 
                                                        # they're considered semantically incorrect paths. 

  chapter_name = @contents[number - 1]
  @title = "Chapter #{number}: #{chapter_name}"

  @chapter = File.read("data/chp#{number}.txt")

  erb :chapter
end

not_found do
  redirect "/"
end

get "/search" do
  @results = chapters_matching(params[:query])
  erb :search
end

helpers do 
  def in_paragraphs(text)
    text.split("\n\n").map.with_index do |line, index| 
      "<p id=paragraph#{index}>#{line}</p>"
    end.join
  end

  def highlight(string, query)
    string.gsub(query, %(<strong>#{query}</strong>)) # What is %(..)
  end
end

def each_chapter
  @contents.each_with_index do |name, index|
    number = index + 1
    contents = File.read("data/chp#{number}.txt")
    yield number, name, contents
  end
end

def chapters_matching(query)
  results = []

  return results unless query

  each_chapter do |number, name, contents|
    matches = {}
    contents.split("\n\n").each_with_index do |paragraph, index|
      matches[index] = paragraph if paragraph.include?(query)
    end
    results << {number: number, name: name, paragraphs: matches} if matches.any?
  end

  results
end



################################################

# get "/chapters/1" do 
#   @title = "Chapter 1"
#   @contents = File.readlines("data/toc.txt")
#   @chapter = File.read("data/chp1.txt")

#   erb :chapter
# end

# get "/show/:name" do
#   "Hi.  My name is #{params[:name]}!"
# end


# view helper example
  # def slugify(text)
  #   text.dowcase.gsub(/\s+/, "-").gsub(/[^\w-]/, "")
  # end


# my method for chapters_matching

# def chapters_matching(query)
#   return nil if !query || query.empty?

#   file_names = Dir.glob("./data/chp*").select do |chapter|
#     File.read(chapter).include?(query)
#   end

#   chapter_numbers = file_names.map { |res| res.gsub(/[^\d]/, '') }.map(&:to_i)
#   chapter_names = chapter_numbers.map { |num| @contents[num - 1] }.map(&:strip)
#   chapter_numbers.zip(chapter_names).sort_by { |num, _| num }
# end