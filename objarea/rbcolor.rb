
if RUBY_PLATFORM =~ /(win|w)32/
  $color = true
  #puts "--RBCOLOR--"
  begin
    #puts "Checking for ANSICON support..."
    if `echo %ANSICON%` =~ /%/ then
      puts "ANSICON support unavailable: using win32console"
      require 'Win32/Console/ANSI' 
    else
      #puts "ANSICON support exists."
    end
  rescue LoadError
    puts "You don't have the win32console gem installed. Do you want to install it? (y/n) [NOTE: If you don't have Ruby installed, type 'n']"
    if gets[0] == 'y'
      puts "[NOTE: if you do not have 'gem.bat' in your path, this will not install anything. Please add it and rerun this program if it is not present.]"
      puts "Installing win32console.."
      system("gem install win32console")
      puts "Done. Now run this program again."
      Process.exit
    else
      puts "Color will now be off."
      $color=false
    end
  end
  #puts "--RBCOLOR--"
end


module Color
  
  def self.strip_color_codes(str)
    str.gsub(/@[brmcygwdBRMCYGWD]/,'').gsub(/@@/, '@')
  end
  
	def crint(str, defcolor="d")
		$colortable["@D"]=$colortable["@"+defcolor]
		newstr = str.to_s.gsub(/@[brmcygwdBRMCYGWD@]/, $color ? $colortable : '')
		print newstr
		$colortable["@D"]=$colortable["@w"]
	end

	def cputs(str, defcolor="w")
		crint(str, defcolor)
		puts
	end

	$colortable = {
		"@D" => "\e[0m",
    "@d" => "\e[0m",
		"@m" => "\e[0;35m",
		"@b" => "\e[0;34m",
		"@c" => "\e[0;36m",
		"@g" => "\e[0;32m",
		"@y" => "\e[0;33m",
		"@r" => "\e[0;31m",
		"@w" => "\e[1;30m",
		"@M" => "\e[1;35m",
		"@B" => "\e[1;34m",
		"@C" => "\e[1;36m",
		"@G" => "\e[1;32m",
		"@Y" => "\e[1;33m",
		"@R" => "\e[1;31m",
		"@W" => "\e[0;37m",
		"@@" => "@"
	}
end
