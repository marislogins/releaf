require 'spec_helper'
describe Releaf::ContentController do
  before do
    @admin = auth_as_admin
    # build little tree
    @root = FactoryGirl.create(:node, name: "Root")
    FactoryGirl.create(:node, parent_id: @root.id)
    @sub_root = FactoryGirl.create(:node, parent_id: @root.id)
    FactoryGirl.create(:node, parent_id: @sub_root.id)

    @node = FactoryGirl.create(:node, name: "Main")

    visit releaf_nodes_path
  end

  describe "tree collapsing" do
    context "when not opened before" do
      it "do not show node children", js: true do
        expect(page).to have_css('li[data-id="' + @root.id.to_s + '"].collapsed')
      end
    end

    context "when click to uncollapse node" do
      it "show node children", js: true do
        find('li[data-id="' + @root.id.to_s + '"] > .collapser-cell button').click

        expect(page).to have_css('li[data-id="' + @root.id.to_s + '"]:not(.collapsed)')
      end

      it "keep opened node children visibility permanent", js: true do
        find('li[data-id="' + @root.id.to_s + '"] > .collapser-cell button').click
        page.wait_until{ @admin.settings.last.try(:value) == true }
        visit releaf_nodes_path

        expect(page).to have_css('li[data-id="' + @root.id.to_s + '"]:not(.collapsed)')
      end

      it "keep closed node children visibility permanent", js: true do
        find('li[data-id="' + @root.id.to_s + '"] > .collapser-cell button').click
        page.wait_until{ @admin.settings.last.try(:value) == true }
        find('li[data-id="' + @root.id.to_s + '"] > .collapser-cell button').click
        page.wait_until{ @admin.settings.last.try(:value) == false }
        visit releaf_nodes_path

        expect(page).to have_css('li[data-id="' + @root.id.to_s + '"].collapsed')
      end
    end
  end

  describe "go_to node" do
    before do
      visit edit_releaf_node_path @node
    end

    context "when clicking on toolbox button", js: true do
      it "displays go to option in menu" do
        find('.toolbox button').click
        wait_for_ajax_to_complete
        expect(page).to have_css('.toolbox-items li a.ajaxbox', text: "Go to", visible: true)
      end
    end

    context "when presing go to link in toolbox list", js: true do
      it "displays go to dialog" do
        find('.toolbox button').click
        wait_for_ajax_to_complete
        find('.toolbox-items li a.ajaxbox', text: "Go to").click
        wait_for_ajax_to_complete
        expect(page).to have_css('.dialog.goto-node-dialog', visible: true)
      end
    end

    context "when going to node from toolbox list", js: true do
      it "navigates to targeted node's edit view" do
        find('.toolbox button').click
        wait_for_ajax_to_complete
        find('.toolbox-items li a.ajaxbox', text: "Go to").click
        wait_for_ajax_to_complete
        find('.dialog.goto-node-dialog .action-tree ul li .node-cell a', text: "Root").click

        expect(page).to have_css('.view-edit .edit_resource h2.header', text: 'Root', visible: true)
      end
    end
  end

  describe "copy node to" do
    context "when pressing toolbox icon", js: true do
      it "displays copy link" do
        find('li[data-id="' + @root.id.to_s + '"] > .toolbox-cell button').click
        wait_for_ajax_to_complete
        expect(page).to have_css('.toolbox-items li a.ajaxbox', text: "Copy", visible: true)
      end
    end

    context "when pressing copy link", js: true do
      it "displays copy dialog" do
        find('li[data-id="' + @root.id.to_s + '"] > .toolbox-cell button').click
        wait_for_ajax_to_complete
        find('.toolbox-items li a.ajaxbox', text: "Copy").click
        wait_for_ajax_to_complete
        expect(page).to have_css('.dialog.copy-node-dialog', visible: true)
      end
    end

    context "when copying node", js: true do
      it "shows copied node in tree" do
        find('li[data-id="' + @node.id.to_s + '"] > .toolbox-cell button').click
        wait_for_ajax_to_complete
        find('.toolbox-items li a.ajaxbox', text: "Copy").click
        wait_for_ajax_to_complete
        find('.dialog.copy-node-dialog .action-tree ul li .node-cell button', text: "Root").click
        find('li[data-id="' + @root.id.to_s + '"] > .collapser-cell button').click

        expect(page).to have_css('li > .node-cell a', text: "Main", count: 2, visible: true)
      end
    end
  end

  describe "move node to" do
    context "when pressing toolbox icon", js: true do
      it "displays move link" do
        find('li[data-id="' + @root.id.to_s + '"] > .toolbox-cell button').click
        wait_for_ajax_to_complete
        expect(page).to have_css('.toolbox-items li a.ajaxbox', text: "Move", visible: true)
      end
    end

    context "when pressing move link", js: true do
      it "displays move dialog" do
        find('li[data-id="' + @root.id.to_s + '"] > .toolbox-cell button').click
        wait_for_ajax_to_complete
        find('.toolbox-items li a.ajaxbox', text: "Move").click
        wait_for_ajax_to_complete
        expect(page).to have_css('.dialog.move-node-dialog', visible: true)
      end
    end

    context "when moving node to another parent", js: true do
      it "removes selected node from current position" do
        find('li[data-id="' + @node.id.to_s + '"] > .toolbox-cell button').click
        wait_for_ajax_to_complete
        find('.toolbox-items li a.ajaxbox', text: "Move").click
        wait_for_ajax_to_complete
        find('.dialog.move-node-dialog .action-tree ul li .node-cell button', text: "Root").click

        expect(page).not_to have_css('li > .node-cell a', text: "Main", visible: true)
      end

      it "moves selected node to new position" do
        find('li[data-id="' + @node.id.to_s + '"] > .toolbox-cell button').click
        wait_for_ajax_to_complete
        find('.toolbox-items li a.ajaxbox', text: "Move").click
        wait_for_ajax_to_complete
        find('.dialog.move-node-dialog .action-tree ul li .node-cell button', text: "Root").click
        find('li[data-id="' + @root.id.to_s + '"] > .collapser-cell button').click

        expect(page).to have_css('li > .node-cell a', text: "Main", count: 1, visible: true)
      end
    end
  end
end
