module MoCo

  module CompilerOption

    def self.convert(value)
      case value
      when nil, 'true'
        true
      when 'false'
        false
      when INTEGER
        value.to_i
      when FLOAT
        value.to_f
      when SYMBOL
        value.delete(':').to_sym
      when SINGLE_QUOTED, DOUBLE_QUOTED
        strip_quotes(value)
      when ARRAY
        to_array(value)
      else
        value
      end
    end

  private

    INTEGER = /^[+-]?\d+$/
    FLOAT   = /^[+-]?\d*\.\d+$/
    SYMBOL  = /^:[^:]+$/
    ARRAY   = /:/
    SINGLE_QUOTED = /^'[^']*'$/
    DOUBLE_QUOTED = /^"[^"]*"$/

    def self.strip_quotes(value)
      value[1..-2]
    end

    private_class_method :strip_quotes

    def self.to_array(value)
      values = value.split(':')
      rejoin_symbols(values)
      values.map { |value| convert(value) }
    end

    private_class_method :to_array

    def self.rejoin_symbols(values)
      values.each_cons(2) do |v1, v2|
        v2.insert(0, ':') if v1.empty?
      end
      values.delete('')
    end

    private_class_method :rejoin_symbols

  end

end
