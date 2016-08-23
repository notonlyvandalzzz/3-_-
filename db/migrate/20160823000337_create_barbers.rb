class CreateBarbers < ActiveRecord::Migration
  def change
  	  	create_table :barbers do |t|
  		t.text :name
  		t.timestamps

  		Barbers.create :name => 'Darth Wader'
  		Barbers.create :name => 'Luke Skywalker'
  		Barbers.create :name => 'R2D2'
  		Barbers.create :name => 'C3PO'
  		Barbers.create :name => 'Yoda'
  		end
  end
end
