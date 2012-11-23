module Message
  extend self
  
  def get_object_by_id(id, scope = GameObject)
    ObjectSpace.each_object(scope) do |obj|
      return obj if obj.id == id
    end
    return nil
  end
  
  def get_objects_cr global, sender
    olist = []
    if !global
      ObjectSpace.each_object(Thing) do |obj|
        olist << obj if obj.current_room == get_object_by_id(sender).current_room
      end
    else
      ObjectSpace.each_object(GameObject) do |obj|
        olist << obj
      end
    end
    return olist.delete_if {|x| x.kind_of? Area}
  end
  
  def broadcast message, global=false
    command, body, sender=message[:command], message[:body], message[:sender]
    o_sender = get_object_by_id(sender, GameObject)
    case command
    when "glecho"
      cputs body
    end
    if global or o_sender.current_room == $player.current_room
      case command
      when "precho"
        cputs message
      when "get"
        if sender == $player.id
          cputs "Taken. (#{get_object_by_id(body, Item).name.capitalize})", "d"
        else
          cputs "#{o_sender.name.capitalize} picks up #{get_object_by_id(body, Item).name}@D.", "d"
        end
      when "drop"
        if sender == $player.id
          cputs "Dropped. (#{get_object_by_id(body, Item).name.capitalize})", "d"
        else
          cputs "#{o_sender.name.capitalize} drops #{get_object_by_id(body, Item).name}@D.", "d"
        end
      when "look"
        if sender != $player.id
          if body == $player.id
            cputs "#{o_sender.name} looks at you.", "d"
          else
            cputs "#{o_sender.name} looks at #{get_object_by_id(sender, Thing).name}@D.", "d"
          end
        end
      when "say"
        if sender == $player.id
          cputs "@DYou say '#{body}@D'@d", "C"
        else
          cputs "@D#{o_sender.name.capitalize} says '#{body}@D'@d", "C"
        end
      when "scan"
        if sender != $player.id
          cputs "@D#{o_sender.name.capitalize} scans all directions, looking for signs of life.@d", "d"
        end
      when "move"
        if sender != $player.id
          cputs "@D#{o_sender.name.capitalize} leaves #{body}.@d", "d"
        end
      when "arrival"
        if sender != $player.id
          cputs "@D#{o_sender.name.capitalize} arrives from the #{body}.@d", "d"
        end
      when "give"
        sbody = body.split(/\\/)
        item = sbody[0]
        char = sbody[1]
        if sender == $player.id
          cputs "@DYou give #{get_object_by_id(item, Item).name} to #{get_object_by_id(char, Character).name.capitalize}.@d", "d"
        else
          cputs "@D\nYou recieve #{get_object_by_id(item, Item).name} from #{o_sender.name}.@d", "d"
        end
      when "shoot"
        if message == "shotinroom"
          if o_sender.sender == $player.id
            cputs "\n@DA shot from you enters the room.", "d"
          else
            cputs "\n@DA shot from #{o_sender.sender} enters the room.", "d"
          end
        end
      when "recharge"
        if sender == $player.id
          cputs "You have been recharged!", "d" 
        else
          cputs "\n#{o_sender.name} recharges!"
        end
      when "hunt"
        if sender != $player.id
          cputs "\n#{o_sender.name} studies the earth for tracks", "d"
        end
      when "imhit"
        hitter = get_object_by_id(body, Character)
        o_sender.incur_lag(2)
        if sender == $player.id
          cputs "\n#{hitter.to_s.capitalize} has shot you! You will respawn in 2 seconds.", "d"
        else
          cputs "\nYou watch as #{sender} is shot by #{hitter}.", "d"
        end
      end
    end
    command_resolved = false
    get_objects_cr(global, sender).each do |obj|  
      obj.m_ints.each do |match, exec|
        command_match = (match[0] =~ command)
        message_match = (match[1] =~ body)
        sender_match  = (match[2] =~ sender )
        if command_match and message_match and sender_match
          command_resolved = (command == "input")
          Thread.new do
            obj.send(exec, message)
          end
        end
      end
    end
    return RV[:command_resolved => command_resolved]
  end
end