require_relative './gitlab'

describe 'Timer' do
  before(:each) do
    @t = Timer.new(5)
  end

  example 'seconds elapsed' do
    @t.run
    expect(@t.seconds).to be(5)
  end

  example 'calls' do
    @t.run
    expect(@t.calls).not_to be(0)
  end
end
