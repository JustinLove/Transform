require 'transform'

describe Transform::Header do
  let :output do [] end
  let :subject do Transform::Header.new(output) end

  it 'create' do
    subject.create('foo')
    output.should == %w{foo}
  end

  it 'copy' do
    subject.copy('foo')
    output.should == %w{foo}
  end

  it 'rename' do
    subject.rename('foo', 'bar')
    output.should == %w{bar}
  end

  it 'map' do
    subject.map('foo', 'bar') { :blarg }
    output.should == %w{bar}
  end

  it 'map with array args' do
    subject.map(['blarg', 'bleep'], 'bar') { :blarg }
    output.should == %w{bar}
  end

  it 'creates in order' do
    subject.create('one')
    subject.create('two')
    output.should == %w{one two}
  end

  it 'renames in order' do
    subject.rename('1', 'one')
    subject.rename('2', 'two')
    output.should == %w{one two}
  end

  it 'maps in order' do
    subject.map('1', 'one') { :first }
    subject.map('2', 'two') { :second }
    output.should == %w{one two}
  end

  it 'runs a block' do
    context = nil
    object = Transform::Header.new(output) do context = self end
    context.should == object
  end
end

describe Transform::Body do
  context 'without a block' do
    let :columns do %w{numbers n} end
    let :input do [%w{one 1}] end
    def output; subject.output_row; end
    let :subject do Transform::Body.new(columns, input) end

    it 'noop' do
      subject
      output.should == []
    end

    it 'shift is a noop' do
      subject.shift == []
    end

    it 'shifts nil if empty' do
      subject.shift
      subject.shift.should == nil
    end

    it 'create' do
      subject.create('foo')
      output.should == ['']
    end

    it 'copy' do
      subject.copy('numbers')
      output.should == ['one']
    end

    it 'rename' do
      subject.rename('numbers', 'letters')
      output.should == ['one']
    end

    it 'map' do
      subject.map('numbers', 'letters') do |number| number.upcase end
      output.should == ['ONE']
    end

    it 'map with array args' do
      subject.map(['numbers', 'n'], 'amalgam') do |number,n| number+n end
      output.should == ['one1']
    end

    it 'copy out of oder' do
      subject.copy('n')
      output.should == ['1']
    end

    it 'rename out of order' do
      subject.rename('n', 'x')
      output.should == ['1']
    end

    it 'map out of order' do
      subject.map('n', 'x') do |n| n.to_i.succ.to_s end
      output.should == ['2']
    end

    it 'creates multiple' do
      subject.create('foo')
      subject.create('bar')
      output.should == ['', '']
    end

    it 'copies multiple' do
      subject.copy('numbers')
      subject.copy('n')
      output.should == ['one', '1']
    end

    it 'renames multiple' do
      subject.rename('numbers', 'letters')
      subject.rename('n', 'x')
      output.should == ['one', '1']
    end

    it 'maps multiple' do
      subject.map('numbers', 'letters') do |number| number.upcase end
      subject.map('n', 'x') do |n| n.to_i.succ.to_s end
      output.should == ['ONE', '2']
    end
  end

  context 'with a block' do
    let :columns do %w{numbers n} end
    let :input do [%w{one 1}, %w{two 2}] end
    def output; subject.output_row; end
    let :first_row do ['', 'one', '1', 'ONE'] end
    let :second_row do ['', 'two', '2', 'TWO'] end
    let :subject do
      Transform::Body.new(columns, input) do
        create 'foo'
        copy 'numbers'
        rename 'n', 'x'
        map 'numbers', 'letters' do |number|
          number.upcase
        end
      end
    end

    it 'noop' do
      subject
      output.should == []
    end

    it 'shift' do
      subject.shift.should == first_row
    end

    it 'shift twice' do
      subject.shift.should == first_row
      subject.shift.should == second_row
    end

    it 'process' do
      out = []
      subject.process_into(out)
      out.should == [first_row, second_row]
    end
  end
end

describe Transform do
  let :one_row do 
    [%w{numbers n}, %w{one 1}]
  end

  let :two_rows do
    [%w{numbers n}, %w{one 1}, %w{two w}]
  end

  let :output do [] end

  it 'noop' do
    Transform.transform(one_row, output) {}
    output.should == [[], []]
  end

  it 'process one row' do
    Transform.transform(one_row, output) do
      create 'foo'
    end
    output.should == [%w{foo}, ['']]
  end

  it 'process two rows' do
    Transform.transform(two_rows, output) do
      create 'foo'
    end
    output.should == [%w{foo}, [''], ['']]
  end
end

