class AddJoyceTables < ActiveRecord::Migration
  def self.up
    create_table 'joyce_activities', :force => true do |t|
      t.string      'verb', :null => false
      t.references  :actor, :polymorphic => true, :null => false
      t.references  :obj, :polymorphic => true
      t.timestamps
    end
    add_index(:joyce_activities, :created_at)

    create_table 'joyce_streams', :force => true do |t|
      t.string      'name'
      t.integer     :owner_id
      t.string      :owner_type, :null => false
      t.timestamps
    end
    add_index(:joyce_streams, :owner_type)
    add_index(:joyce_streams, [:owner_id, :owner_type])

    create_table 'joyce_activities_streams', :id => false, :force => true do |t|
      t.references  :activity, :null => false
      t.references  :stream, :null => false
    end

    create_table 'joyce_activities_targets', :id => false, :force => true do |t|
      t.string      'name'
      t.references  :activity, :null => false
      t.references  :target, :polymorphic => true, :null => false
    end

    create_table 'joyce_streams_subscribers', :force => true do |t|
      t.references  :subscriber, :polymorphic => true, :null => false,
        :index => { :name => "index_joyce_streams_subscribers_on_subscriber" }
      t.references  :stream, :null => false
      t.datetime    'started_at', :null => false
      t.datetime    'ended_at'
    end
  end

  def self.down
    drop_table 'joyce_activities'
    drop_table 'joyce_streams'
    drop_table 'joyce_activities_streams'
    drop_table 'joyce_activities_targets'
    drop_table 'joyce_streams_subscribers'
  end
end
