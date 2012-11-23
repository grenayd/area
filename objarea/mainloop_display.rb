module Utility
  extend self
  
  def get_exits(cr = current_room)
    str = "You can go "
    exits={}
    EXIT_LIST.each do |exit|
      leads_to = cr.send(exit).room
      exits[exit] = leads_to if leads_to != "0"
    end
    exitstrs=[]
    EXIT_LIST.each do |n|
      sn=n.to_s
      exitstrs << if $show_exit_path
        if $exit_path_style=="id"
          "#{NAME_TO_REAL_NAME[sn[0].downcase]} to #{exits[n].id}"
        else
          "#{NAME_TO_REAL_NAME[sn[0].downcase]} to @C#{exits[n] ? exits[n].name : "(Blocked Exit)"}@G"
        end
      else
        NAME_TO_REAL_NAME[sn[0].downcase]
      end if exits[n]
    end
    str+= if exitstrs.size <= 2 then exitstrs.join(" or ") else exitstrs.join(", ").gsub(/,([^,]+)$/,', or\1') end + ?.
    str = "I see no exits." if exits=={}
    return str
  end
  
  def wrap_text(txt, col = 80) 
    txt.gsub(/(.{1,#{col}})( +|$\n?)|(.{1,#{col}})/, "\\1\\3\n") 
  end
  
  def pad(text, desired_len, options={})
    options[:pad_with] ||= " "
    len = Color.strip_color_codes(text).length
    text + options[:pad_with] * (desired_len - len)
  end
end

module Mainloop
  extend self
  
  
  
  $prompt ||= "\"@G>>@d \""
  def main
    inp = nil
    while true
      break if inp == "quit"
      crint eval $prompt
      inp = $stdin.gets.chomp
      inp.split(/;/).each do |i|
        $stack = [*$stack, *i]
      end
    end
  end
end

trace_var :$stack, proc{ |v|
  until v == []
    $player.i_do v.pop
  end
}

$stack = []