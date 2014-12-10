module Releaf::Builders::View
  include Releaf::Builders::Base
  include Releaf::Builders::Template

  def output
    safe_join do
      [header, section]
    end
  end

  def header
    tag(:header) do
      [breadcrumbs, flash_notices, header_extras]
    end
  end

  def section
    tag(:section) do
      section_blocks
    end
  end

  def breadcrumbs
    breadcrumb_items = template_variable("breadcrumbs")
    return nil unless breadcrumb_items.present?

    tag(:nav) do
      tag(:ul, class: "block breadcrumbs") do
        safe_join do
          last_item = breadcrumb_items.last
          breadcrumb_items.each.collect do |item, index|
            breadcrumb_item(item, item == last_item)
          end
        end
      end
    end
  end

  def breadcrumb_item(item, last)
    tag(:li) do
      if item[:url].present?
        tag(:a, href: item[:url]) do
          item[:name]
        end
      else
        item[:name]
      end << ( fa_icon("small chevron-right") unless last).to_s
    end
  end

  def flash_notices
    safe_join do
      flash.collect do |name, item|
        flash_item(name, item)
      end
    end
  end

  def flash_item(name, item)
    tag(:div, class: "flash", 'data-type' => name, :'data-id' => (item.is_a? (Hash)) && (item.has_key? "id") ? item["id"] : nil) do
      item.is_a?(Hash) ? item["message"] : item
    end
  end

  def header_extras
  end



  def section_blocks
    [section_header, section_body, section_footer]
  end

  def section_header
    tag(:header) do
      [tag(:h1, section_header_text), section_header_extras]
    end
  end

  def section_header_extras; end
  def section_body; end

  def section_footer
    tag(:footer, class: section_footer_class) do
      footer_tools
    end
  end

  def section_footer_class
    :main
  end


  def footer_tools
    tag(:div, class: "tools") do
      footer_blocks
    end
  end

  def footer_blocks
    [footer_primary_block, footer_secondary_block]
  end

  def footer_primary_block
    tag(:div, class: "primary") do
      footer_primary_tools
    end
  end

  def footer_secondary_block
    tag(:div, class: "secondary") do
      footer_secondary_tools
    end
  end

  def footer_primary_tools; end
  def footer_secondary_tools; end
end