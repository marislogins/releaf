module Leaf
  class ContentController < BaseController

    def build_secondary_panel_variables
      @nodes = Node.roots
      super
    end

    #def build_secondary_panel

      #@secondary_panel = render_to_string( :partial => "objects", :layout => false, :locals => build_secondary_panel_variables)
    #end

    def index
      authorize! :index, Node
      respond_to do |format|
        format.html
      end
    end

    def create
      content_type = _node_params[:content_type].constantize
      authorize! :create, content_type
      @item = current_object_class.new(_node_params)
      content_object = content_type.create!(:text => "--")
      @item.content_id = content_object.id

      respond_to do |format|
        if @item.save
          format.html { redirect_to url_for(:action => "index")}
        else
          format.html { render action: "new" }
        end
      end
    end

    def update
      @item = current_object_class.find(params[:id])
      authorize! :edit, @item

      respond_to do |format|
        if @item.update_attributes(_node_params)
          format.html { redirect_to url_for(:action => "edit") }
        else
          format.html { render action: "edit" }
        end
      end
    end

    def new
      super
      @order_nodes = Node.where(:parent_id => (params[:parent_id] ? params[:parent_id] : nil))
      @position = 1
      @item.parent_id = params[:parent_id]
      form_extras
    end

    def edit
      super
      @order_nodes = Node.where(:parent_id => (@item.parent_id ? @item.parent_id : nil)).
        where('id != :id', :id => params[:id])

      if @item.higher_item
        @position = @item.higher_item.position
      else
        @position = 1
      end

      form_extras
    end

    def form_extras
      Rails.application.eager_load!
      @base_models = NodeBase.subclasses

      if @item.is_controller_node
        @controller_properties = @item.controller::DEF
      end

      #if @item.id && @item.content_id
        #@content_object = @item.content_object
      #end
    end

    #def base_controllers
      #controllers = []
      #Rails.application.routes.named_routes.routes.map{|key, r|
        #if !r.defaults[:controller].to_s.empty?
          #class_name = "#{r.defaults[:controller]}_controller".classify.constantize
          #if class_name < LeafController
            #item = {
              #:controller => class_name,
              #:path => key,
              #:def => class_name::DEF,
              #:values => {}
              ##:path => r.path
            #}
            #saved = CData.find_by_controller(class_name)
            #if saved
              #item[:values] = saved.data
            #end
            #controllers << item
          #end
        #end
      #}
      #@asd = controllers
    #end

    #def index
      #controllers = []
      #Rails.application.routes.named_routes.routes.map{|key, r|
        #if !r.defaults[:controller].to_s.empty?
          #class_name = "#{r.defaults[:controller]}_controller".classify.constantize
          #if class_name < LeafController
            #item = {
              #:controller => class_name,
              #:path => key,
              #:def => class_name::DEF,
              #:values => {}
              ##:path => r.path
            #}
            #saved = CData.find_by_controller(class_name)
            #if saved
              #item[:values] = saved.data
            #end
            #controllers << item
          #end
        #end
      #}
      #@asd = controllers
    #end

    #def save
      #params[:controller] = params[:controller_name]
      #@item = CData.find_by_controller(params[:controller])
      #if @item
        #@item.update_attributes(params)
      #else
        #@item = CData.new(params)
      #end

      #@item.save
      #redirect_to leaf_content_path
    #end

    def current_object_class
      Node
    end

    protected

    def _node_params
      allowed_params = [:parent_id, :name, :content_type, :slug, :position, :data, :visible, :protected, :content_attributes]

      # if @item && @item.content_object
      #   allowed_params.push({object_data: @item.content_object.class.column_names - ["id", "created_at", "updated_at"]})
      # end

      # params.require(current_object_class_name).permit(*allowed_params)
      params.require(current_object_class_name).permit(*allowed_params)
    end

    private

    def node_params(action)
      # make sure none of actions, that are defined by BaseController can update item
      []
    end

  end
end