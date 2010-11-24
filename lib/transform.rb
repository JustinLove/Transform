# Perform simple transformations on row,column type data
#
# See {Transform::Body::BlockAPI} for description of each operation
#
# @example Operate directly on csv files
#   require 'transform/csv'
#   Transform.csv2csv('mint.csv', 'ynab.csv') do
#     # Date, Description, Original Description, Amount, Transaction Type, Category, Account Name, Labels, Notes
#     copy 'Date'
#     rename 'Description', 'Payee'
#     rename 'Original Description', 'Memo'
#     map ['Amount', 'Transaction Type'], 'Inflow' do |amount, type|
#       amount if type == 'credit'
#     end
#     map ['Amount', 'Transaction Type'], 'Outflow' do |amount, type|
#       amount if type == 'debit'
#     end
#     # Date, Payee, Category, Memo, Outflow, Inflow
#   end
#
# @example Directly on Arrays (or other objects that use #shift and #<<)
#   require 'transform'
#   output = Transform.transform([%w{name digit}, %w{one 1}], []) do
#     map 'name', 'NAME' do |name| name.upcase end
#     map 'digit', 'digit' do |digit| digit.to_i.succ.to_s end
#   end
#   p output
module Transform
  # Gem version, if it ever becomes one
  VERSION = '0.0.0'

  # Read one stream and output to the other
  #
  # Notice that Body respects both protocols below
  #
  # @param [ #shift ] input data source; should produce an array in response to #shift
  # @param [ #ltlt ] output data sink; should respond to #<<
  # @return [output] object specified as output parameter
  # @yield block specifying the transformation to target columns using {Body::BlockAPI}
  def self.transform(input, output, &block)
    output << Header.new([], &block).output_row
    Body.new(input.shift, input, &block).process_into(output)
    return output
  end

  # dsl context for generating headers rows
  class Header
    # @param [#ltlt] output: an object (array, csv, io) which supports #<<
    def initialize(output, &block)
      @output_row = output
      instance_eval(&block) if block_given?
    end

    # mostly for testing/debugging
    attr_reader :output_row # @private

    # Add header item to row
    def write(column)
      @output_row << column
    end
    private :write

    # API methods for passed block.  See {Body::BlockAPI} for complete documentation
    module BlockAPI
      # @see Body::BlockAPI#create
      def create(column)
        write(column)
      end

      # @see Body::BlockAPI#copy
      def copy(column)
        write(column)
      end

      # @see Body::BlockAPI#rename
      def rename(from, to)
        write(to)
      end

      # @see Body::BlockAPI#map
      def map(from, to)
        write(to)
      end
    end
    include BlockAPI
  end

  # dsl context for interpreting body rows
  class Body
    # @param [Array] columns: list of header names
    # @param [#shift] input: data source, #shift should return Array
    def initialize(columns, input, &block)
      @column_map = {}
      columns.each_with_index do |c, i| @column_map[c] = i end
      @input = input
      self.class.__send__(:define_method, :map_row, &block) if block_given?
      prepare!
    end

    # mostly for testing/debugging
    attr_reader :output_row # @private

    # @abstract placeholder so it doesn't crash if the block wasn't defined
    def map_row
    end
    private :map_row

    # Grab the text row, and re-init output
    def prepare!
      @input_row = @input.shift
      @output_row = @input_row ? [] : nil
      self
    end
    private :prepare!

    # Read one row from the input source and process
    # @return [Array] processed row
    def shift #ought to be !, but such is the protocol
      map_row unless @input_row.nil?
      output = @output_row
      prepare!
      output
    end

    # Process the entire input and append to:
    # @param [#ltlt] output: an object which accecpts an array via #<<
    def process_into(output)
      while (!@input_row.nil?)
        output << shift
      end
    end

    # Get the data associated with a single column
    # @param [String] column name
    def read(column)
      if column.kind_of?(Array)
        column.map {|c| read(c)}
      else
        @input_row[@column_map[column]]
      end
    end
    private :read

    # Append a single column's processed data
    # @param [String] data to append
    def write(data)
      @output_row << data
    end
    private :write

    # API to be used by blocks to {Transform.transform} (and {Transform.csv2csv})
    module BlockAPI
      # A new blank column
      #
      # @example
      #   create 'Approved'
      #
      # @param [String] column name
      def create(column)
        write('')
      end

      # Preserve as-is
      #
      # @example
      #   copy 'Date'
      #
      # @param [String] column name
      def copy(column)
        write(read(column))
      end

      # Preserve data, but generate a different column name/header
      #
      # @example
      #   rename 'Original Description', 'Memo'
      #
      # @param [String] from: existing name
      # @param [String] to: new name
      def rename(from, to)
        write(read(from))
      end

      # Transform the data in column(s) 'from' to new column 'to'
      #
      # @example
      #   map ['Amount', 'Transaction Type'], 'Outflow' do |amount, type|
      #     amount if type == 'debit'
      #   end
      #
      # @param [String, Array] from: column name or list of names.
      #   Values of these columns correspond one-to-one with block parameters
      # @param [String] to: output column name
      #
      # @yield processing on the column data use {BlockAPI}
      # @yieldparam [String...] data: one argumenet per column named by 'from' argument
      # @yieldreturn [String] data value for the new column
      def map(from, to)
        write(yield read(from))
      end
    end
    include BlockAPI
  end
end
