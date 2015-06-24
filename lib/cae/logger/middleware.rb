require 'logger'

module Cae
	class Logger
		# middleware to insert a Cae::Logger into rack.logger
		class Middleware
			def initialize(app)
				@app = app
			end
			def call(env)
				env['rack.logger'] = Logger.new
				@app.call(env)
			end
		end
	end
end
