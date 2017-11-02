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

    def possibly_sensitive?(message)
      message.respond_to?(:possibly_sensitive?) and message.possibly_sensitive?
    end

    def render(context)
      if helper.visible? and helper.message and possibly_sensitive?(helper.message)
        context.save do
          layout = main_message(context)
          context.set_source_rgb(*([0xff / 256.0,0x28 / 256.0,0]))
          context.show_pango_layout(layout)

          pixbuf = GdkPixbuf::Pixbuf.new(file: Skin.get("dont_like.png".freeze))
          context.translate(42, 0)
          context.scale(20.0/pixbuf.width, 20.0/pixbuf.height)
          context.set_source_pixbuf(pixbuf)
          context.paint
        end
      end
    end

    def height
      if possibly_sensitive?(helper.message)
        [main_message.size[1] / Pango::SCALE, 18].max
      else
        0
      end
    end

    private

    def main_message(context = dummy_context)
      layout = context.create_pango_layout
      layout.font_description = Pango::FontDescription.new(UserConfig[:mumble_basic_font])
      layout.alignment = Pango::Alignment::LEFT
      if possibly_sensitive?(helper.message)
        layout.text = " NSFW"
      else
        layout.text = ""
      end
      layout
    end
  end
end
