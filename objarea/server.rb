class CharacterProgramDoesNotExist < Exception; end

class VServer
  def initialize
  end
  
  def request(sender, request)
    body = request[:body]
    command_resolved = sender.broadcast_pr("input", body).values[0][:command_resolved]
    if request[:type] == :command
      parse_hash = LanguageParser.parse(body)
      target_command = $commands.keys.map {|val| val[0..parse_hash[:verb].length-1]}.index(parse_hash[:verb])
      if target_command
        if sender.lag != 0
          until sender.lag == 0
          end
        end
        result = sender.send($commands[$commands.keys[target_command]],  body.split[1..-1].join(" "), parse_hash[:args])
        return result
      else
        return !command_resolved ? "Command not understood." : nil
      end
    elsif request[:type] == :prog
      if sender.respond_to? body
        if sender.lag != 0
          until sender.lag == 0
          end
        end
        result = (sender.send body)
        return result
      else
        raise CharacterProgramDoesNotExist, "No character prog: #{body}"
      end
    end
  end
end