# -*- coding: utf-8 -*-

require 'gtk2'

Plugin.create :subparts_nsfw do
  class Message
    def sensitive?
      @value[:possibly_sensitive]
    end
  end

  class Gdk::SubPartsNsfw < Gdk::SubParts
    register

    class << self
      attr_accessor :top_shift
    end
    @top_shift = 0 # Gdk::SubPartsNsfw.top_shift = 4 などと調整できる

    def sensitive?(message)
      message.respond_to?(:sensitive?) and message.sensitive?
    end

    def render(context)
      if helper.visible? and helper.message and sensitive?(helper.message)
        context.save do
          layout = main_message(context)
          context.set_source_rgb(*([0xff / 256.0,0x28 / 256.0,0]))
          context.translate(0, self.class.top_shift)
          context.show_pango_layout(layout)
          context.translate(0, -self.class.top_shift)

          pixbuf = Skin["dont_like.png"].pixbuf(width: scale(20), height: scale(20))
          context.translate(scale(42), 0)
          context.set_source_pixbuf(pixbuf)
          context.paint
        end
      end
    end

    def height
      @height ||= sensitive?(helper.message) ? [main_message.size[1] / Pango::SCALE, 18].max : 0
    end

    private

    if Environment::VERSION < [3, 9, 0, 0]
      def main_message(context = dummy_context)
        _main_message(context, Pango::FontDescription.new(UserConfig[:mumble_basic_font]))
      end

      def scale(val)
        val
      end
    else
      def main_message(context = Cairo::Context.dummy)
        _main_message(context, helper.font_description(UserConfig[:mumble_basic_font]))
      end

      def scale(val)
        helper.scale(val)
      end
    end

    def _main_message(context, font_description)
      layout = context.create_pango_layout
      layout.font_description = font_description
      layout.alignment = Pango::Alignment::LEFT
      if sensitive?(helper.message)
        layout.text = " NSFW"
      else
        layout.text = ""
      end
      layout
    end
  end
end
