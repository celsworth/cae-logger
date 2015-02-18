require 'logger'

require 'cae/logger/ansi_string'
require 'cae/logger/middleware'

# Cae::Logger.defaults[:format_datetime] = "%d/%b/%Y %H:%M:%S"
# Cae::Logger.debug 'debug message'
# Cae::Logger.debug 'some_work runtime' { some_work }

module Cae
	# Padrino-inspired logger complete with colours
	class Logger

		# refinement to add String#ansi
		using AnsiString

		OPTS = {}.freeze
		SEVERITY_COLOURS = {
			'FATAL' =>  [:yellow, :on_red, :bold],
			'ERROR' =>  [:red],
			'WARN'  =>  [:yellow],
			'INFO'  =>  [:green],
			'DEBUG' =>  [:cyan],
			'DEVEL' =>  [:magenta]
		}.freeze

		@defaults = {
			format_datetime: '%F %T.%3N',
			level: ::Logger::DEBUG,
			stream: $stderr
		}

		attr_reader :logger

		class << self
			attr_reader :defaults

			def logger(opts = OPTS)
				@logger ||= new(opts)
			end

			def log(level, msg, &block)
				return log_with_block(level, msg, &block) if block_given?

				logger.logger.send level, msg
			end

			def log_with_block(level, msg, &block)
				began_at = Process.clock_gettime Process::CLOCK_MONOTONIC
				yield
			ensure
				ended_at = Process.clock_gettime Process::CLOCK_MONOTONIC
				msg = "(%.6fs) %s" % [ ended_at - began_at, msg ]
				logger.logger.send level, msg
			end

			def debug(msg, &block) log(:debug, msg, &block) end
			def info(msg, &block)  log(:info, msg, &block)  end
			def warn(msg, &block)  log(:warn, msg, &block)  end
			def error(msg, &block) log(:error, msg, &block) end
			def fatal(msg, &block) log(:fatal, msg, &block) end
		end

		def initialize(opts = OPTS)
			defaults = self.class.defaults
			stream          = opts[:stream]          || defaults[:stream]
			level           = opts[:level]           || defaults[:level]
			format_datetime = opts[:format_datetime] || defaults[:format_datetime]

			@logger = ::Logger.new(stream)
			@logger.level = level
			@logger.formatter = proc do |severity, datetime, _progname, msg|
				fseverity = sprintf '%5.5s', severity
				sprintf "%s %s %s\n",
					datetime.strftime(format_datetime).ansi(:yellow),
					fseverity.ansi(*SEVERITY_COLOURS[severity]),
					Array(msg).join
			end
		end
	end
end
