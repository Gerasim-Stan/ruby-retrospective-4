module UI
  def self.set_style_to_segment(segment, style)
    if style.nil? or segment.frozen?
      segment
    else
      segment.method(style).call
    end
  end

  class TextScreen
    def self.draw
      @components = []
      @components_added_count = 0
      instance_eval &Proc.new
      @components.join
    end

    def self.label(text:, style: nil, border: nil)
      text = "#{border}#{text}#{border}"
      text = text.method(style).call.freeze unless style.nil?
      @components << text
      @components_added_count += 1
    end

    def self.vertical(border: nil, style: nil)
      @components_added_count = 0
      checked_components_count = @components.size - @components_added_count
      yield
      @components.map! { |segment| UI::set_style_to_segment(segment, style) }
      alignment = @components[checked_components_count.. - 1]
        .group_by(&:size).max.first
      set_vertical_alignment(alignment, border)
    end

    def self.set_vertical_alignment(alignment, border)
      checked_components_count = @components.size - @components_added_count
      @components[checked_components_count.. - 1].each do |segment|
        segment.prepend("#{border}") << "#{border}\n"
          .rjust(alignment - segment.size + border.to_s.size * 2 + 1)
      end
    end

    def self.horizontal(border: nil, style: nil)
      @components_added_count = 0
      components_copy = @components.dup
      yield
      @components.map! { |segment| UI::set_style_to_segment(segment, style) }
      components_copy = [(@components - components_copy).join]
      set_horizontal_alignment(components_copy, border)
    end

    def self.set_horizontal_alignment(components_copy, border)
      alignment = @components.group_by(&:size).max.first
      1.upto(@components_added_count) { |index| @components.delete_at(-1) }
      @components += components_copy
      @components.last.prepend("#{border}") << "#{border}"
        .rjust(alignment - @components.last.size + border.to_s.size * 2 - 1)
    end
  end
end

