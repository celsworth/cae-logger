require 'logger'

require 'cae/logger/ansi_string'
require 'cae/logger/middleware'

# Cae::Logger.defaults[:format_datetime] = "%d/%b/%Y %H:%M:%S"
# l = Cae::Logger.new
# l.debug 'debug message'
# l.debug 'some_work runtime' { some_work }

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

		DEFAULTS = {
			format_datetime: '%F %T.%3N',
			level: ::Logger::DEBUG,
			progname: nil,
			stream: $stderr
		}

		class << self
			def defaults
				DEFAULTS
			end
		end

		attr_reader :logger

		def initialize(opts = OPTS)
			defaults = self.class.defaults
			stream          = opts[:stream]          || defaults[:stream]
			level           = opts[:level]           || defaults[:level]
			progname        = opts[:progname]        || defaults[:progname]
			format_datetime = opts[:format_datetime] || defaults[:format_datetime]

			progname = '[%s]' % [ progname.ansi(:yellow) ] if progname

			@logger = ::Logger.new(stream)
			@logger.level = level
			@logger.formatter = proc do |severity, datetime, _progname, msg|
				fseverity = sprintf '%5.5s', severity
				msg = [
					datetime.strftime(format_datetime).ansi(:yellow),
					fseverity.ansi(*SEVERITY_COLOURS[severity]),
					"##{$$}".ansi(:magenta),
					progname,
					Array(msg).join
				].compact.join(' ')

				msg + "\n"
			end
		end

		def log(level, msg, &block)
			return log_with_block(level, msg, &block) if block_given?

			logger.send level, msg
		end

		def log_with_block(level, msg, &block)
			began_at = Process.clock_gettime Process::CLOCK_MONOTONIC
			yield
		ensure
			ended_at = Process.clock_gettime Process::CLOCK_MONOTONIC
			msg = "(%.3fs) %s" % [ ended_at - began_at, msg ]
			logger.send level, msg
		end

		def debug(msg, &block) log(:debug, msg, &block) end
		def info(msg, &block)  log(:info, msg, &block)  end
		def warn(msg, &block)  log(:warn, msg, &block)  end
		def error(msg, &block) log(:error, msg, &block) end
		def fatal(msg, &block) log(:fatal, msg, &block) end

	end
end
