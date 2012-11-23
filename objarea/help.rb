# Objectarea help module
# To load custom help directory: Help.load_help(dir)
class BadHelpDirectoryError < Exception; end

module Help
  @@loaded_helps = []
  def self.load_help dir
    help_files = Dir.glob("#{Dir.pwd}/#{dir}/*")

    help_files.each do |help|
      if Dir.glob("#{help}/name.txt") != [] and Dir.glob("#{help}/body.txt") != [] and Dir.glob("#{help}/keywords.txt")  != []
        
        id = help.split(/\//)[-1].downcase
        name = IO.readlines("#{help}/name.txt")[0].chomp
        body = IO.readlines("#{help}/body.txt")
        keywords = IO.readlines("#{help}/keywords.txt").join(" ").split(" ").map(&:downcase)
        @@loaded_helps.delete_if {|h| h.id == id}
        @@loaded_helps << HelpFile.new(id, name, keywords, body)
      else
        raise BadHelpDirectoryError, "one or more files are missing"
      end
    end
    
    @@loaded_helps
  end

  def self.get_help(keywords)
    possibilities = []
    
    @@loaded_helps.each do |help|
    
      #if there is a match...
      if keywords.size == 1 and keywords[0] == help.id
        return RV[SUCCESS, [help]]
      else  
        possibilities << help if keywords.clone.delete_if {|k| [*help.keywords, help.id].map{ |hk| hk[0..k.length-1]}.index(k)} == []
      end
    end
    
    return RV[SUCCESS, possibilities]
  end
end

class HelpFile
  attr_accessor :keywords, :name, :body, :id
  def initialize *argv
    @id = argv.shift
    @name = argv.shift
    @keywords = argv.shift
    @body = argv.shift
  end
end