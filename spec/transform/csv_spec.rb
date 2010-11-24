require 'transform/csv'
require 'tempfile'

describe Transform do
  context 'csv support' do
    let :input_string do
      "numbers,n\none,1"
    end

    let :input_csv do
      CSV.new(input_string)
    end

    let :inputfile do
      file = Tempfile.new('inputfile')
      file.write(input_string)
      file.close
      file
    end

    let :output_string do '' end

    let :output_csv do
      CSV.new(output_string)
    end

    let :outputfile do
      file = Tempfile.new('outputfile')
      file.close
      file
    end

    it 'raw strings' do
      Transform.transform(input_csv, output_csv) do
        rename 'numbers', 'letters'
      end
      output_string.should == "letters\none\n"
    end

    it 'file helper' do
      begin
        Transform.csv2csv(inputfile.path, outputfile.path) do
          rename 'numbers', 'letters'
        end
        outputfile.open.read.should == "letters\none\n"
      ensure
        inputfile.close unless inputfile.closed?
        outputfile.close unless outputfile.closed?
      end
    end
  end
end

