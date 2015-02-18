require 'ansi/code'
require 'ansi/chain'

# refinement to add String#ansi in Cae::Logger (doesn't pollute String globally)

module Cae
	class Logger
		module AnsiString
			refine String do
				def ansi(*codes)
					codes.empty? ? ANSI::Chain.new(self) : ANSI::Code.ansi(self, *codes)
				end
			end
		end
	end
end
