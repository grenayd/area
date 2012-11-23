require_relative 'objectarea.rb'

module AreaCompiler
  
  def self.compile_area area_name
    area = {}
    result = ""
    declarations = ""
    
    (room_files = Dir.glob("house/**/*.room/").map {|x| x.gsub(/\//, '_')[0..-7]}).each do |room|
      
    end
  end
end

if __FILE__ == $0
  area_name=ARGV[0]
  
  if !(File.directory? area_name)
    raise "Area directory could not be found"
  end
  
  area = nil
  File.open("./#{area_name}-area.rb", "w") do |f|
    f.write(AreaCompiler.compile_area(area_name))
  end
  #require 'pry'
  #binding.pry
end