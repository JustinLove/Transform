module Transform
  VERSION = '0.0.0'

  def self.transform(input, output, &block)
    output << Header.new([], &block).output_row
    Body.new(input.shift, input, &block).process_into(output)
  end

  class Header
    attr_reader :output_row

    def write(column)
      @output_row << column
    end

    def initialize(output, &block)
      @output_row = output
      instance_eval(&block) if block_given?
    end

    def create(column)
      write(column)
    end

    def copy(column)
      write(column)
    end

    def rename(from, to)
      write(to)
    end

    def map(from, to)
      write(to)
    end
  end

  class Body
    def initialize(columns, input, &block)
      @column_map = {}
      columns.each_with_index do |c, i| @column_map[c] = i end
      @input = input
      self.class.__send__(:define_method, :map_row, &block) if block_given?
      prepare!
    end
    attr_reader :output_row

    def map_row
    end

    def prepare!
      @input_row = @input.shift
      @output_row = @input_row ? [] : nil
      self
    end

    def shift #ought to be !, but such is the protocol
      map_row unless @input_row.nil?
      output = @output_row
      prepare!
      output
    end

    def process_into(output)
      while (!@input_row.nil?)
        output << shift
      end
    end

    def read(column)
      if column.kind_of?(Array)
        column.map {|c| read(c)}
      else
        @input_row[@column_map[column]]
      end
    end

    def write(data)
      @output_row << data
    end

    def create(column)
      write('')
    end

    def copy(column)
      write(read(column))
    end

    def rename(from, to)
      write(read(from))
    end

    def map(from, to)
      write(yield read(from))
    end
  end
end
