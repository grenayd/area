

module Pager
  @@pagesize = 23
  @@page_prompt = "@G<(Q)uit or (M)ore? (ENTER = more, anything else = quit)>@d"
  
  def self.show_text text # String Array
    line = 0
    len = text.size-1
    opt = "m"
    
    from = 0
    to = 0
    
    until to == len or opt == "q"
      
      
      from = to+1
      to += @@pagesize
      to = len if to > len
      
      text[from..to].each do |l| 
        cputs l 
      end
      
      opt = ""
      
      until opt == "m" or opt == "q" or to == len
        crint @@page_prompt
        opt = gets.chomp
        
        opt = (opt == "m" or opt == "") ? "m" : "q"
      end
    end
  end
end