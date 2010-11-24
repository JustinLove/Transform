require 'transform'
require 'csv'

module Transform
  def self.csv2csv(inputfile, outputfile, &block)
    CSV.open(inputfile, 'rb') do |input|
      CSV.open(outputfile, 'wb') do |output|
        transform(input, output, &block)
      end
    end
  end
end
