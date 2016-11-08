# -*- coding: utf-8 -*-
                                                                                                                                                                                                                                               
require 'gtk2'

Plugin.create :subparts_nsfw do
  class Message
    def possibly_sensitive?
      @value[:possibly_sensitive]
    end 
  end 

  class Gdk::SubPartsNsfw < Gdk::SubParts
    register

    def render(context)
      if helper.visible? and helper.message and helper.message.possibly_sensitive?
        context.save do
          layout = main_message(context)
          context.set_source_rgb(*([0xff / 256.0,0x28 / 256.0,0]))
          context.show_pango_layout(layout)
        end 
      end 
      @last_height = height
    end 

    def height
      if helper.message.possibly_sensitive?
        main_message.size[1] / Pango::SCALE
      else
        0   
      end 
    end 

    private

    def main_message(context = dummy_context)
      layout = context.create_pango_layout
      layout.font_description = Pango::FontDescription.new(UserConfig[:mumble_basic_font])
      layout.alignment = Pango::ALIGN_LEFT
      if helper.message.possibly_sensitive?
        layout.text = "NSFW"
      else
        layout.text = ""
      end 
      layout end 

  end 
end
