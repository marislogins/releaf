require 'releaf/acts_as_node/active_record/acts/node'
require 'releaf/acts_as_node/action_controller/acts/node'

module ActsAsNode
  @classes = []

  def self.register_class(class_name)
    @classes << class_name unless @classes.include? class_name
  end

  def self.classes
    @classes
  end

  if defined? Rails::Railtie
    require 'rails'
    class Railtie < Rails::Railtie
      initializer 'acts_as_node.insert' do
        ActiveSupport.on_load :active_record do
          ActsAsNode::Railtie.insert_into_active_record
        end

        ActiveSupport.on_load :action_controller do
          ActsAsNode::Railtie.insert_into_action_controller
        end
      end
    end
  end

  class Railtie
    def self.insert
      insert_into_active_record
      insert_into_action_controller
    end

    def self.insert_into_active_record
      if defined?(ActiveRecord)
        ActiveRecord::Base.send(:include, ActiveRecord::Acts::Node)
      end
    end

    def self.insert_into_action_controller
      if defined?(ActionController)
        ActionController::Base.send(:include, ActionController::Acts::Node)
      end
    end
  end
end

ActsAsNode::Railtie.insert
