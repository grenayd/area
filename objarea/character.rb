

class RV
  
  def initialize(*argv)
    @values = argv
  end
  
  def self.[] *argv
    new(*argv)
  end
  
  def == other
    !!(@values.index other)
  end
  
  attr_accessor :values
end

Help.load_help("main_help")

class Character < GameObject
  include ObjectContainer
  attr_accessor :lag
  
  def self.inherited(sub)
    sub.send(:define_method, :initialize) do
      @infohash =  Marshal.load(Marshal.dump(self.class.class_variable_get("@@infohash")))
      @name = @infohash[:name]
      @shortdesc = @infohash[:shortdesc]
      @longdesc = @infohash[:longdesc]
      @m_ints = (@infohash[:m_ints] or {})
      @inventory = (@infohash[:inventory] or [])
      @keywords = (@infohash[:keywords] or [])
      @current_room = @infohash[:current_room]
      @hidden = (@infohash[:hidden] or false)
      @lag = 0
      
      def current_room(*argv);@current_room;end
      
      def current_room=(room);@current_room = room;end
      
      if !sub.class_variable_defined?("@@instances")
        sub.class_variable_set("@@instances", [self])
      else
        tmp = sub.class_variable_get("@@instances")
        tmp.push self
        sub.class_variable_set("@@instances", tmp)
      end
      @id = "#{@infohash[:id]}-#{self.class.class_variable_get("@@instances").length}"
      @infohash=nil
    end
  end
  
  def incur_lag val
    @lag = val
    Thread.new do
      sleep @lag
      @lag = 0
    end
  end
  
  def echo *argv
    cputs(*argv) if self == $player
  end
  
  def i_do input
    result = $server.request(self,{:type=>:command, :body=>input})
    puts result if self==$player and result != SUCCESS
    return result
  end
  
  def run_prog name
    result = $server.request(self,{:type=>:prog, :body=>name})
  end
  
  def get(input="",infohash={})
    if (infohash[:to] or infohash[:into] or infohash[:at]) or (infohash[:in] and infohash[:from])
      return "I don't understand your sentence."
    end
    
    infohash[:from] ||= infohash[:indirect_object]
    if infohash[:from]
      container = target(infohash[:from],:mode => "ir", :who => "ir", :cont => false)
      return "I don't see that container." if container == 76676
      return "I can't take from more than one container." if container.length > 1
      container = container[0]
      return "That isn't a container!" if !container.container
    else
      container = current_room
    end
    
    return "I don't know what you're trying to get." if !infohash[:direct_object]
    items = if container == current_room
      target(infohash[:direct_object], :mode=>"r", :who=>"i", :cont=>false)
    else
      container.target(infohash[:direct_object], :mode=>"i", :who=>"i", :cont=>false)
    end
    items = [76676] if items == 76676
    items.each do |item|
      if container.index(item)
        broadcast_pr("get", item.id)
        container.remove item
        @inventory.push item
      else
        return "I don't see that item #{container == current_room ? "on the ground" : "in #{container.inspect}"}."
      end
    end
    return SUCCESS
  end
  
  def drop(input="",infohash={})
    one = [infohash[:indirect_object], infohash[:in], infohash[:into]].count {|n| n}
    
    if (infohash[:to] or infohash[:at] or infohash[:from]) or (one != 1 and one != 0)
      return "I don't understand your sentence."
    end
    
    infohash[:in] ||= infohash[:indirect_object] ||= infohash[:into]
    if infohash[:in] then
      container = target(infohash[:in], :mode => "ir", :who => "ir", :cont=>false)
    else
      container = [current_room]
    end
    
    return "I can't put something into more than one container!" if container.length > 1
    container = container[0]
    return "That isn't a container" if !container.container
    return "I don't see that container." if container == 76676
    
    return "I don't know what you're trying to drop." if !infohash[:direct_object]
    items = target(infohash[:direct_object], :mode => "i", :who => "i", :cont => false)
    return "I don't see that in your inventory" if items == 76676
    
    items.each do |item|
      if inventory.index(item)
        broadcast_pr("drop", item.id)
        remove item
        container << item
      else
        return "I don't see that in your inventory."
      end
    end
    return SUCCESS
  end
  
  def give(input="",infohash={})
    one = [infohash[:indirect_object], infohash[:to]].count {|n| n}
    
    if (infohash[:in] or infohash[:into] or infohash[:at] or infohash[:from]) or (one > 1)
      return "I don't understand your sentence."
    end
    
    if !infohash[:direct_object]
      return "Give what to whom?"
    end
    if one == 0
      return "Give that to whom?"
    end
    
    infohash[:to] ||= infohash[:indirect_object]
    
    items = target(infohash[:direct_object], :mode=>"i", :who=>"i")
    if items == 76676
      return "I don't see that in your inventory."
    end
    
    to = target(infohash[:to], :mode=>"r", :who=>"c")
    if to == 76676
      return "I don't see that character here."
    end
    if to.length > 1
      return "I can only give items to one character at a time."
    end
    to = to[0]
    items.each do |item|
      broadcast_pr("give", "#{item.id}\\#{to.id}")
      remove(item)
      to.inventory << item
    end
    
    return SUCCESS
  end
  
  alias :put :drop
  
  def look(input="",infohash={})
    if (infohash[:at] and infohash[:direct_object]) or (infohash[:direct_object] and infohash[:in]) or infohash[:from] or infohash[:into] or infohash[:to]
      return "I don't understand your sentence."
    end
    
    infohash[:at] ||= infohash[:direct_object]
    
    if infohash[:in]
      container= target(infohash[:in], :mode=>"ir", :who=>"i")
      if container == 76676
        return "I don't see that."
        elsif container.length > 1
        return "I can only look inside one thing at a time."
      else
        container = container[0]
        broadcast_pr("look_in", container.id)
        crint "@G#{container.capitalize} containes:\n@d#{container.format_inventory}\n"
        return SUCCESS
      end
    end
    
    if !infohash[:at]
      broadcast_pr("look", "room")
      display_info
      return SUCCESS
    end
    
    object = target(infohash[:at], :mode=>"ir", :who=>"a")
    if object == 76676
      return "I don't see that."
      elsif object.length > 1
      return "I can only look at one thing at a time."
    else
      broadcast_pr("look", object[0].id)
      puts object[0].longdesc
      return SUCCESS
    end
  end
  
  def display_inventory(input="",infohash={})
    crint "@GYou have:\n@d#{format_inventory}"
  end
  
  def north(input="",infohash={}); move_dir("north"); end
  def south(input="",infohash={}); move_dir("south"); end
  def east(input="",infohash={}) ; move_dir("east") ; end
  def west(input="",infohash={}) ; move_dir("west") ; end
  
  def move_dir(dir)
    r_exit = current_room.send(dir.to_sym)
    o_exit = current_room.send("#{dir[0].capitalize}Exit".to_sym)
    if r_exit =~ /^SPWALL-(.*)$/
      Thread.new do
        eval $1
      end
      return SUCCESS
    end
    
    if r_exit == "0"
      return "Sorry, you cannot go that way."
    end
    
    if o_exit.door == "closed"
      return "That door is closed."
    end
    
    broadcast_pr("move", dir)
    self.current_room = r_exit
    display_info if self == $player
    broadcast_pr("arrival", NAME_TO_REAL_NAME[INVERTED_NAME[REAL_NAME_TO_NAME[dir]]])
    return SUCCESS
  end
  
  def new_draw_map room = current_room
    nw=map_traverse_NW room
    ne=map_traverse_NE room
    sw=map_traverse_SW room
    se=map_traverse_SE room
    
    map=RoomGrid.new($mapdepth*2+1)
    [nw,ne,sw,se].each do |set|
      set.each do |pos,r|
        ["NWall","EWall","WWall","SWall","UWall","DWall"].each do |dir|
          map[pos[0]+3,pos[1]+3,dir]=(r.send("#{dir[0]}Exit").room == "0")
        end
        el = EXIT_LIST.clone
        map[pos[0]+3,pos[1]+3,"Terrain"]=r.terrain
        map[pos[0]+3,pos[1]+3,"HExits"]=el.delete_if {|exit| !r.send(exit).hidden}.map(&:to_s)
        map[pos[0]+3,pos[1]+3,"Doors"]=el.delete_if {|exit| r.send(exit).door == "closed"}.map(&:to_s)
        map[pos[0]+3,pos[1]+3,"ID"]=r.id
      end
    end
    map.display(ne.merge(nw).merge(se).merge(sw), "@#{current_room.color}").each {|l| cputs l.join}
  end
  
  def display_info cr = current_room
    cputs "@D#{cr.name}@d", "G"
    cputs "#{Utility.wrap_text("  #{cr.longdesc}", 79)}@d"
    new_draw_map
    cputs "@D#{Utility.get_exits current_room}@d", "c"
    
    chars = $player.target("all", :mode=>"r", :who=>"c")
    
    cr.inventory.each do |obj|
      cputs "    #{obj.shortdesc}@d"
    end
    chars.each do |obj|
      cputs "@D#{obj.shortdesc}@d", "Y"
    end
    return nil
  end
  
  def say(input="",infohash={})
    broadcast_pr("say", input)
  end
  
  def scan(input="", infohash={}, return_raw = false)
    broadcast_pr("scan", "")
    scanobjs = {}
    objs = current_room.target("all", :mode=>"r", :who=>"c")
    lines = []
    if objs != 76676
      scanobjs[:here] = objs
      
      lines << "@GRight here you see:@d"
      
      objs.each do |obj|
        lines << "@d  - #{obj}"
      end
    end
    
    EXIT_NAME_LIST.each do |dir|
      scanobjs[dir]={}
      
      if current_room.send(dir) != "0"
        objs = current_room.send(dir).target("all", :mode=>"r", :who=>"c")
        if objs != 76676
          lines << "@G#{dir.to_s.capitalize} of here you see:@d"
          
          scanobjs[dir][:here] = objs
          
          objs.each do |obj|
            lines << "@d  - #{obj}"
          end
        end
        scanobjs[dir][dir] = {}
        if current_room.send(dir).send(dir) != "0"
          objs = current_room.send(dir).send(dir).target("all", :mode=>"r", :who=>"c")
          if objs != 76676
            scanobjs[dir][dir][:here] = objs
            
            lines << "@G2 #{dir.to_s.capitalize} of here you see:@d"
            
            objs.each do |obj|
              lines << "@d  - #{obj}"
            end
          end
          scanobjs[dir][dir][dir]={}
          if current_room.send(dir).send(dir).send(dir) != "0"
            objs = current_room.send(dir).send(dir).send(dir).target("all", :mode=>"r", :who=>"c")
            if objs != 76676
              scanobjs[dir][dir][dir][:here] = objs
              
              lines << "@G3 #{dir.to_s.capitalize} of here you see:@d"
              
              objs.each do |obj|
                lines << "@d  - #{obj}"
              end
            end
          end
        end
      end
    end
    if lines == [] or lines == [$player] then lines = ["You see nothing interesting here."] end
    if self == $player
      lines.each {|l| cputs l}
    end
    #incur_lag(0.1)
    return RV[SUCCESS, scanobjs]
  end
  
  def help(input = "", infohash={})
    keywords = input.split[0..-1]
    results =  Help.get_help(keywords).values[1]
    
    if results == []
      return "No helpfiles match the keywords '#{keywords.join(", ")}'."
    end
    
    
    if results.size == 1
      helpfile = results[0]
      helptext = []
      helptext << " @c#{"-"*77}@D"
      helptext << "@c|@C#{Utility.pad("    Help for @W#{helpfile.name}", 77)}@c|"
      helptext << "@c|@C#{Utility.pad("    Keywords: @W#{helpfile.keywords}",77)}@c|"
      helptext << "@c|@w#{"-"*77}@c|@d"
      helptext.push( *helpfile.body.map{ |line| "@c|@D#{Utility.pad(line.chomp, 77)}@c|" } )
      helptext << " @c#{"-"*77}@D"
      Pager.show_text(helptext)
      return SUCCESS
    else #results.size > 1
      puts "One or more helpfiles matched the keyword(s) '#{keywords.join(", ")}':"
      cputs "@D#{results.map {|h| h.id}.join("\n@D")}",  "C"
    end
    
  end
end