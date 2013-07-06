module Puma
  class Runner
    def initialize(cli)
      @cli = cli
      @options = cli.options
      @app = nil
    end

    def daemon?
      @options[:daemon]
    end

    def development?
      @options[:environment] == "development"
    end

    def log(str)
      @cli.log str
    end

    def error(str)
      @cli.error str
    end

    def output_header(mode)
      min_t = @options[:min_threads]
      max_t = @options[:max_threads]

      log "Puma #{Puma::Const::PUMA_VERSION} starting in #{mode} mode..."
      log "* Min threads: #{min_t}, max threads: #{max_t}"
      log "* Environment: #{ENV['RACK_ENV']}"
    end

    def redirect_io
      stdout = @options[:redirect_stdout]
      stderr = @options[:redirect_stderr]
      append = @options[:redirect_append]

      if stdout
        STDOUT.reopen stdout, (append ? "a" : "w")
        STDOUT.sync = true
        STDOUT.puts "=== puma startup: #{Time.now} ==="
      end

      if stderr
        STDERR.reopen stderr, (append ? "a" : "w")
        STDERR.sync = true
        STDERR.puts "=== puma startup: #{Time.now} ==="
      end
    end

    def load_and_bind
      unless @cli.config.app_configured?
        error "No application configured, nothing to run"
        exit 1
      end

      # Load the app before we daemonize.
      begin
        @app = @cli.config.app
      rescue Exception => e
        log "! Unable to load application"
        raise e
      end

      @cli.binder.parse @options[:binds], self
    end

    def app
      @app ||= @cli.config.app
    end
  end
end
