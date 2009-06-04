class AddListenerData < ActiveRecord::Migration
  def self.up
  Listener.delete_all

  Listener.create(:key                 => 'orders.input',
                  :subscriber_url      => '/queue/orders.input',
                  :receiver_url          => 'http://localhost:3000') 

  Listener.create(:key                 => 'inventory',
                  :subscriber_url      => '/topic/inventory.stock_level', 
                  :receiver_url          => 'http://localhost:3000') 
  end

  def self.down
    Listener.delete_all
  end
end
