MoCo.args '--option coffee:header src:lib/moco/support'

class AppleScriptCompiler < MoCo::Compiler

  require_library 'open3'
  register 'applescript'

  def self.compiled_extension
    'scpt'
  end

  def compile
    cmd = ['osacompile', '-o', compiled_file, source_file]
    message = Open3.popen3(*cmd) { |_, _, stderr| stderr.read.strip }
    unless message.empty?
      error = StandardError.new(message)
      error = MoCo::CompileError.new(error, source_file)
      write_compiled(error_text(error))
      raise error
    end
  end

  def error_text(error)
    applescript = <<-EOF
      tell application "AppleScript Runner"
      	display alert "%s" giving up after 10
      	return
      end
    EOF
    message = "File: #{error.file}\n\nLine: #{error.line}\n\n#{error.message}"
    message = message.gsub('\\') { '\\\\' }.gsub('"', '\"')
    applescript % message
  end

end
