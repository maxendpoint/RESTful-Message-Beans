class AddListenerData < ActiveRecord::Migration
  def self.up
    Listener.delete_all
      
    Listener.create(:key                   => 'orders.input',
                    :subscriber_url        => '/queue/orders.input',
                    :subscriber_host       => 'localhost',
                    :subscriber_port       => '61613',
                    :subscriber_user       => '',
                    :subscriber_password   => '',
                    
                    :receiver_login_url    => 'http://localhost:3000/login',
                    :receiver_delivery_url => 'http://localhost:3000/documents/new') 

    Listener.create(:key                   => 'inventory',
                    :subscriber_url        => '/topic/inventory.stock_level', 
                    :subscriber_host       => 'localhost',
                    :subscriber_port       => '61613',
                    :subscriber_user       => '',
                    :subscriber_password   => '',
                    
                    :receiver_login_url    => 'http://localhost:3000/login',
                    :receiver_delivery_url => 'http://localhost:3000/documents/new') 
  end

  def self.down
    Listener.delete_all
  end
end
