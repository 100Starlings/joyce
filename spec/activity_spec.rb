require 'spec_helper'

describe Joyce::Activity do
  
  describe "validation" do
    context "with missing parameters" do
      [
        {:verb => Acted},
        {:actor => Thing.create(:name => "Ulysses")}
      ].each do |params|
        context "with #{params}" do
          it { Joyce::Activity.new(params).should_not be_valid }
        end
      end
    end
  end
  
  describe "#get_targets" do
    let(:activity) { create(:activity) }
    it { activity.get_targets.should be_empty }
    
    context "with default target" do
      before do
        @default_target = build(:thing)
        Joyce::ActivityTarget.create(:activity => activity, :target => @default_target)
      end
      
      it { activity.get_targets.should == [@default_target] }
    end
    
    context "with named target" do
      before do
        @test_target = build(:thing)
        Joyce::ActivityTarget.create(:activity => activity, :target => @test_target, :name => :test)
      end
      
      it { activity.get_targets(:test).should == [@test_target] }
    end
    
    context "with array targets" do
      before do
        @test_targets = 2.times.map{ |i| build(:thing) }
        @test_targets.each do |target|
          Joyce::ActivityTarget.create(:activity => activity, :target => target, :name => :test)
        end
      end
      
      it { activity.get_targets(:test).should == @test_targets }
    end
  end
  
  describe "#set_targets" do
    let(:activity) { create(:activity) }
    let(:thing) { build(:thing) }
    
    context "when param is not a hash" do
      it { expect{ activity.set_targets(thing) }.to raise_error ArgumentError }
    end
    
    it "should set the target" do
      expect{
        activity.set_targets(:thing => thing)
      }.to change{ activity.get_targets(:thing) }.to([thing])
    end
    
    context "when hash value is an array" do
      let(:things) { 2.times.map{ |i| create(:thing) } }
      
      it "should set the targets" do
        expect{
          activity.set_targets(:things => things)
        }.to change{ activity.get_targets(:things) }.to(things)
      end
      
      context "when empty" do
        it "should not do anything" do
          expect{
            activity.set_targets(:things => [])
          }.not_to change{ activity.get_targets(:things) }
        end
      end
    end
    
  end
  
  describe "scopes" do
    describe ".since" do
      before do
        Timecop.travel(2.weeks.ago) do
          @activity_to_drop = create(:activity)
        end
        @activity_to_show = create(:activity)
      end
      
      it { Joyce::Activity.since(1.week.ago).should == [@activity_to_show] }
    end
    
    describe ".with_* scopes" do
      before { @wrong_activity = create(:activity) }
      
      shared_examples_for "a .with_* scope" do
        it "should include the activity with the specified component" do
          subject.should include(@right_activity)
        end

        it "should not include any activity without the specified component" do
          subject.should_not include(@wrong_activity)
        end
      end

      describe ".with_actor" do
        let(:actor) { create(:thing) }
        it { Joyce::Activity.with_actor(actor).should be_empty }

        context "with activities" do
          before{ @right_activity = create(:activity, :actor => actor) }

          subject { Joyce::Activity.with_actor(actor) }
          it_should_behave_like "a .with_* scope"
        end
      end

      describe ".with_verb" do
        let(:verb) { Acted }
        it { Joyce::Activity.with_verb(verb).should be_empty }

        context "with activities" do
          before{ @right_activity = create(:activity, :verb => Acted) }

          subject { Joyce::Activity.with_verb(verb) }
          it_should_behave_like "a .with_* scope"
        end
      end

      describe ".with_object" do
        let(:obj) { create(:thing) }
        it { Joyce::Activity.with_object(obj).should be_empty }

        context "with activities" do
          before{ @right_activity = create(:activity, :obj => obj) }

          subject { Joyce::Activity.with_object(obj) }
          it_should_behave_like "a .with_* scope"
        end
      end

      describe ".with_target" do
        let(:target) { create(:thing) }
        it { Joyce::Activity.with_target(target).should be_empty }

        context "with activities" do
          context "with a single target" do
            before do
              @right_activity = create(:activity)
              @right_activity.set_targets(:target => target)
            end

            subject { Joyce::Activity.with_target(target) }
            it_should_behave_like "a .with_* scope"
          end

          context "with an array of targets" do
            before do
              @right_activity = create(:activity)
              @right_activity.set_targets(:targets => [target, create(:thing)])
            end

            subject { Joyce::Activity.with_target(target) }
            it_should_behave_like "a .with_* scope"
          end
        end
      end
      
      describe ".with_component" do
        let(:actor) { create(:thing) }
        let(:verb) { Acted }
        let(:object) { create(:thing) }
        let(:target) { create(:thing) }
        before do
          @right_activity = create(:activity, :actor => actor, :verb => verb, :obj => object)
          @wrong_activity = create(:activity)
        end
        
        context "with an actor" do
          subject { Joyce::Activity.with_component(actor) }
          it_should_behave_like "a .with_* scope"
        end
        
        context "with a verb" do
          subject { Joyce::Activity.with_component(verb) }
          it_should_behave_like "a .with_* scope"
        end
        
        context "with an object" do
          subject { Joyce::Activity.with_component(object) }
          it_should_behave_like "a .with_* scope"
        end
        
        context "when activity has a target" do
          before{ @right_activity.set_targets(:target => target) }
          
          context "with a target" do
            subject { Joyce::Activity.with_component(target) }
            it_should_behave_like "a .with_* scope"
          end
        end
      end
    end
    
    describe ".without_* scopes" do
      shared_examples_for "a .without_* scope" do
        it "should not include the activity with the specified component" do
          subject.should_not include(@wrong_activity)
        end

        it "should include any activity without the specified component" do
          subject.should include(@right_activity)
        end
      end
      
      describe ".without_actor" do
        let(:actor) { create(:thing) }
        it { Joyce::Activity.without_actor(actor).should be_empty }

        context "with activities" do
          before{ @right_activity = create(:activity) }
          before{ @wrong_activity = create(:activity, :actor => actor) }

          subject { Joyce::Activity.without_actor(actor) }
          it_should_behave_like "a .without_* scope"
        end
      end
      
      describe ".without_verb" do
        let(:verb) { Acted }
        it { Joyce::Activity.without_verb(verb).should be_empty }

        context "with activities" do
          before{ @right_activity = create(:activity) }
          before{ @wrong_activity = create(:activity, :verb => verb) }

          subject { Joyce::Activity.without_verb(verb) }
          it_should_behave_like "a .without_* scope"
        end
      end
      
      describe ".without_object" do
        let(:object) { create(:thing) }
        it { Joyce::Activity.without_object(object).should be_empty }

        context "with activities" do
          before{ @wrong_activity = create(:activity, :obj => object) }
          
          context "with activities without object" do
            before{ @right_activity = create(:activity) }

            subject { Joyce::Activity.without_object(object) }
            it_should_behave_like "a .without_* scope"
          end
          
          context "with activities with a different object" do
            before{ @right_activity = create(:activity, :obj => create(:thing)) }

            subject { Joyce::Activity.without_object(object) }
            it_should_behave_like "a .without_* scope"
          end
        end
      end
      
      describe ".without_target" do
        let(:target) { create(:thing) }
        it { Joyce::Activity.without_target(target).should be_empty }

        context "with activities" do
          before do
            @wrong_activity = create(:activity)
            @wrong_activity.set_targets(:target => target)
          end
          
          context "with activities without target" do
            before{ @right_activity = create(:activity) }

            subject { Joyce::Activity.without_target(target) }
            it_should_behave_like "a .without_* scope"
          end
          
          context "with activities with a different target" do
            before do
              @right_activity = create(:activity)
              @right_activity.set_targets(:target => create(:thing))
            end

            subject { Joyce::Activity.without_target(target) }
            it_should_behave_like "a .without_* scope"
          end
        end
      end
    end
  end
  
  describe "#verb=" do
    before{ @activity = Joyce::Activity.new }
    
    context "with a class" do
      before{ @activity.verb = Object }
      
      it{ @activity.read_attribute(:verb).should == "Object" }
    end
    
    context "with nil" do
      before{ @activity.verb = nil }
      
      it { @activity.read_attribute(:verb).should be_nil }
    end
  end
  
  describe "#verb" do
    before{ @activity = Joyce::Activity.new }
    
    context "with a class" do
      before{ @activity.verb = Object }
      
      it{ @activity.verb.should == Object }
    end
    
    context "with nil" do
      before{ @activity.verb = nil }
      
      it { @activity.verb.should be_nil }
    end
  end
  
  describe "#subscribers" do
    let(:actor) { create(:person) }
    let(:activity) { Joyce.publish_activity(:actor => actor, :verb => Acted) }
    
    it { activity.subscribers.should be_empty }
    it { activity.subscribers.should be_a(Array) }
    
    context "with a current subscriber" do
      let(:subscriber) { create(:thing) }
      before{ subscriber.subscribe_to(actor) }
      
      it { activity.subscribers.should == [subscriber] }
    end
    
    context "with a past subscriber" do
      let(:subscriber) { create(:thing) }
      before do
        Timecop.travel(1.week.ago) do
          subscriber.subscribe_to(actor)
          subscriber.unsubscribe_from(actor)
        end
      end
      
      it { activity.subscribers.should be_empty }
    end
    
    context "when subscribed to multiple streams for the same activity" do
      let(:object) { create(:person) }
      let(:activity) { Joyce.publish_activity(:actor => actor, :verb => Acted, :obj => object) }
      let(:subscriber) { create(:thing) }
      before do
        subscriber.subscribe_to(actor)
        subscriber.subscribe_to(object)
      end
      
      it { activity.subscribers.should == [subscriber] }
    end
  end
  
  describe "#destroy" do
    let(:actor) { create(:thing) }
    let(:object) { create(:thing) }
    let(:targets) { 2.times.map{ create(:thing) } }
    before do
      @activity = create(:activity, :actor => actor, :obj => object)
      @activity.set_targets(:targets => targets)
    end
    
    subject { @activity.destroy }
    
    it "should remove the activity" do
      expect{
        subject
      }.to change{ Joyce::Activity.count }.by(-1)
    end
    
    it "should not remove the actor instance" do
      expect{
        subject
      }.not_to change{ actor.class.count }
    end
    
    it "should not remove the object instance" do
      expect{
        subject
      }.not_to change{ object.class.count }
    end
    
    it "should not remove the target instance" do
      expect{
        subject
      }.not_to change{ targets.first.class.count }
    end
    
    it "should remove association with targets" do
      expect{
        subject
      }.to change{ Joyce::ActivityTarget.count }.by(-targets.size)
    end
    
    context "with a stream" do
      before{ @activity.streams << create(:stream, :owner => actor) }
      
      it "should not remove the stream instance" do
        expect{
          subject
        }.not_to change{ Joyce::Stream.count }
      end
      
      it "should remove association with targets" do
        expect{
          subject
        }.to change{ @activity.streams.count }.by(-1)
      end
    end
  end
  
  context "when the actor is destroyed" do
    before{ @activity = create(:activity) }
    
    it "should destroy the activity" do
      expect{
        @activity.actor.destroy
      }.to change{ Joyce::Activity.count }.by(-1)
    end
  end
  
  context "when the object is destroyed" do
    before{ @activity = create(:activity, :obj => create(:thing)) }
    
    it "should destroy the activity" do
      expect{
        @activity.obj.destroy
      }.to change{ Joyce::Activity.count }.by(-1)
    end
  end
  
end
