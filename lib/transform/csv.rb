# Require this file explicitly to enable the shortcut csv file support
# e.g. require 'transform/csv'
require 'transform'
require 'csv'

module Transform
  # Helper class method for working directly with .csv files
  #
  # @note Not included by default; require 'transform/csv'
  #
  # @param [String] filename
  # @param [String] filename
  # @yield block specifying the transformation to target columns using {Body::BlockAPI}
  def self.csv2csv(inputfile, outputfile, &block)
    CSV.open(inputfile, 'rb') do |input|
      CSV.open(outputfile, 'wb') do |output|
        transform(input, output, &block)
      end
    end
  end
end
