class Array
  def subset?(a)
    (self - a).length == 0
  end
end

class LocationError < Exception;end

module Thing
  def target term, arghash={}
    mode = (arghash[:mode] or "r")
    who  = (arghash[:who] or false)
    cont = (arghash[:nocont] or true)
    raise LocationError, "cannot have 'g' and 'r' modifiers set at same time" if mode =~ /g/ and mode =~ /r/
    possibilities = []
    keywords = []
    target_index=0
    if term =~ /\A(\d+|all)\.(.*)\z/
      target_index = ($1 == "all" ? $1 : $1.to_i-1)
      term = $2
    end
    if term =~ /'[a-zA-Z0-9\s]*?'/
      keywords = term[1..-2].split
    else
      keywords << term
    end
              
    if mode =~ /g/
      ObjectSpace.each_object(Thing) do |obj|
        possibilities << obj
      end
    end
    if mode =~ /r/
      possibilities.push(*current_room.inventory.clone)
      ObjectSpace.each_object(Character) do |obj|
        possibilities << obj if obj.current_room == current_room
      end
    end
    if mode =~ /i/
      if self.kind_of? ObjectContainer
        possibilities.push(*inventory.clone)
      else
        return 76676
      end
    end
    
    if !(who =~ /a/)
      if !(who =~ /i/)
        possibilities.delete_if {|x| x.kind_of? Item}
      end
      if !(who =~ /r/)
        possibilities.delete_if {|x| x.kind_of? Room}
      end
      if !(who =~ /c/)
        possibilities.delete_if {|x| x.kind_of? Character}
      end
    end
    
    possibilities.compact!
    maxlen = keywords.max {|x| x.length}.length
    if keywords != ["all"]
      possibilities.keep_if do |el|
        keywords.subset?(el.keywords.map {|x| x[0..maxlen-1]}) or (keywords.length == 1 and keywords[0] == el.id)
      end
    end
    
    result = if target_index == "all" or keywords == ["all"] then
      possibilities 
    else 
      [possibilities[target_index]]
    end.compact.delete_if {|obj| obj.hidden}
    return result == [] ? 76676 : result
  end
end