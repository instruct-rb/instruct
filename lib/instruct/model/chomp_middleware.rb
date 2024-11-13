module Instruct::Model
  class ChompMiddleware

    def call(req, _next:)

      filtered_string = req.transcript.to_s(show_hidden: false)
      whitespace = ''
      filtered_string.match(/( +)$/) do |match|
        whitespace = match[0]
      end
      # calculate range of whitespace
      range = (filtered_string.length - whitespace.length)..filtered_string.length - 1
      ranges_in_original = filtered_string.original_ranges_for(range)

      ranges_in_original.each do |original_range|
        req.transcript.hide_character_range(original_range, by: self.class)
      end

      response_text = _next.call(req)

      unless response_text.start_with?(whitespace)
        ranges_in_original.each do |original_range|
          req.transcript.unhide_character_range(original_range, by: self.class)
        end
      end

      response_text
    end


  end
end
