require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Joyce::ActivityTarget do
  
  describe ".new" do
    context 'without a name' do
      it 'falls back to :name by default' do
        Joyce::ActivityTarget.new.name.should == 'target'
      end
    end
    
    context 'with a name' do
      it 'does not override the default ActiveRecord behaviour' do
        target = Joyce::ActivityTarget.new(name: 'foobar')
        expect(target.name).to eql('foobar')
      end
    end
  end
end
