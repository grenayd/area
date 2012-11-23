module LanguageParser
  def LanguageParser.parse string
    words=string.split
    verb=words.shift
    phrases=words.join(" ").scan(/(?:(in|into|to|at|from) )?((?:(?:the|a|an) )?(?:\d+\.|all\.)?(?:\w+|'[a-zA-Z0-9\s]*?'))/i)
    parsed = {:verb=>verb, :args=>{}}

    phrases.each_with_index do |ph, i|
      args=parsed[:args]
      object = ph[1]
      prep = ph[0]
      
      if (temp=object.scan(/(?:\d+\.|all\.)?(?:\w+|'[a-zA-Z0-9\s]*?')/)[1])
        object=temp
      end
      if !prep
        if i == 0
          if args[:direct_object] then parsed[:error]=true else args[:direct_object]=object end
        elsif i == 1
          if args[:indirect_object] then parsed[:error]=true else args[:indirect_object]=object end
        else
          parsed[:error]=true
        end
      else
        if !args[prep.to_sym] then args[prep.to_sym]=object else parsed[:error]=true end
      end
    end
    return parsed
  end
end