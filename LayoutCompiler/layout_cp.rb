module LayoutCompiler
  def self.from_file name = "area"
    area = AreaLayout.new(IO.readlines(name + ".layout.txt").map {|line| line.chomp.split(//)}, name)
    LayoutHashUtils.convert_to_code(area.compile)
  end
end

module LayoutHashUtils
  
  
  
  def self.convert_to_code area, opts={}
    # OPTIONS: {
    #   :local_variable_prefix => ... # generated local variable: house_a will become: <PREFIX>house_a. Works like a namespace
    # }
    
    initializations = String.new
    assignments = String.new
    area[:rooms].each do |r_id, room_exits|
      
      
      infohash = {}
      infohash.merge!(:id=>"\"#{r_id}\"")
      
      info = begin
        IO.readlines("#{r_id}.info.txt")
      rescue Exception => e
        []
      end
      
      infohash[:name]      = ?" + (info.shift or ""       ).chomp + ?"
      infohash[:long_desc] = ?" + (info.shift or ""       ).chomp + ?"
      infohash[:terrain]   = ?" + (info.shift or "inside" ).chomp + ?"
      infohash[:color]     = ?" + (info.shift or "w"      ).chomp + ?"
      
      
      doors = begin #CLOSED doors. If you want a door that starts out open, open it at initialize time
        IO.readlines("#{r_id}.doors.txt")
      rescue Exception => e
        []
      end
      
      hidden_exits = begin
        IO.readlines("#{r_id}.hexits.txt")
      rescue Exception => e
        []
      end
      
      room_exits.each do |exit_name, leads_to|
        room_exits[exit_name] = if AreaLayout::ROOM_CHARS.index(leads_to)
          "Exit[:room => #{area[:name]}_#{leads_to},   :door => #{!!doors.index(exit_name.to_s)},   :hidden => #{!!hidden_exits.index(exit_name.to_s)}]"
        else
          "Exit[]"
        end
      end
      
      infohash.merge!(room_exits)
      
      
      
      
      
      var_name = "#{opts[:local_variable_prefix]}#{r_id}"
      
      
      initializations += "#{var_name} = Room.new()\n"
      
      assignments += ?\n
      
      infohash.each do |key, value|
        assignments += "#{var_name}[:#{key}] = #{value == "" ? "\"0\"" : value}\n"
      end
      assignments += ?\n
      
    end
    
    return initializations + assignments
  end
end

class AreaLayout
  attr_accessor :area_string, :name
  
  def initialize *argv
     @area_string, @name = argv
     
     fix
  end
  
  def fix
    @area_string.each_with_index do |line, index|
      @area_string[index] = line.map do |char|
        char == " " ? "" : char
      end
    end
  end
  

  def compile
    fix
    area = {}
    
    area[:name] = @name
    area[:rooms] = {}
    
    find_rooms.each do |id, coords| # I would have used |id, (x, y)|, but my IDE doesn't like it
      id = "#{name}_#{id}"
      x, y = coords
      tr = Traverser.new(@area_string, x, y)
      neighbors = tr.look_around
      area[:rooms][id] = {}
      area[:rooms][id][:NExit] = neighbors[:n].downcase
      area[:rooms][id][:EExit] = neighbors[:e].downcase
      area[:rooms][id][:SExit] = neighbors[:s].downcase
      area[:rooms][id][:WExit] = neighbors[:w].downcase
      area[:rooms][id][:UExit] = (neighbors[:nw] == "" ? neighbors[:ne] : neighbors[:nw]).downcase
      area[:rooms][id][:DExit] = (neighbors[:sw] == "" ? neighbors[:se] : neighbors[:sw]).downcase
      
      
    end
    
    return area
  end

  ROOM_CHARS = [*"a".."z", *"1".."9"]
  
  def find_rooms
    rooms = []
    
    @area_string.each_with_index do |line, y|
      line.each_with_index do |char, x|
        if ROOM_CHARS.index char
          rooms << [char, [x, y]]
        end
      end
    end
    
    return rooms
  end
end

class String
  LAYOUT_SPECIAL_CHARS =
    ["\\", "-", "/", "|", "#"]
  
  def is_layout_special?
    return !!LAYOUT_SPECIAL_CHARS.index(self)
  end
  
  def nil_if_empty
    self == "" ? nil : self
  end
end

class Traverser
  attr_accessor :x, :y, :string
  
  def initialize *argv  # String string, positive int x, positive int y
    @string, @x, @y = argv
  end
  
  def look_around
    stretch = 1
    nw = lambda { (@string[@y - stretch][@x - stretch]  if @y-stretch >= 0 and @x-stretch >= 0) or "" }     
    n  = lambda { (@string[@y - stretch][@x          ]  if @y-stretch >= 0                    ) or "" }     
    ne = lambda { (@string[@y - stretch][@x + stretch]  if @y-stretch >= 0                    ) or "" }     
    w  = lambda { (@string[@y          ][@x - stretch]                      if @x-stretch >= 0) or "" }     
    e  = lambda { (@string[@y          ][@x + stretch]                                        ) or "" } 
    
     #these are the ones that may raise an nil[] error  
    sw = lambda { ((@string[@y + stretch] or [])[@x - stretch]                      if @x-stretch >= 0) or "" }     
    s  = lambda { ((@string[@y + stretch] or [])[@x          ]                                        ) or "" }     
    se = lambda { ((@string[@y + stretch] or [])[@x + stretch]                                        ) or "" }     
    
    r_nw, r_n, r_ne, r_w, r_sw, r_e, r_s, r_se = nil, nil, nil, nil, nil, nil, nil, nil
    
    
    until  [r_nw, r_n, r_ne, r_w, r_sw, r_e, r_s, r_se].all?
      r_nw ||= nw[] if !nw[].is_layout_special?
      r_n  ||= n[]  if !n[].is_layout_special?
      r_ne ||= ne[] if !ne[].is_layout_special?
      r_w  ||= w[]  if !w[].is_layout_special?
      r_e  ||= e[]  if !e[].is_layout_special?
      r_sw ||= sw[] if !sw[].is_layout_special?
      r_s  ||= s[]  if !s[].is_layout_special?
      r_se ||= se[] if !se[].is_layout_special?
      stretch += 1
    end
    
    
    
    result={:nw => r_nw, :n => r_n, :ne => r_ne,
            :w  => r_w,             :e  => r_e,
            :sw => r_sw, :s => r_s, :se => r_se}
            
    
    
    return result
  end
end


if __FILE__ == $0
  puts LayoutCompiler.from_file(ARGV[0])
  exit 0
end