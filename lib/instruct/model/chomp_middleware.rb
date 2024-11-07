module Instruct::Model
  class ChompMiddleware

    def call(req, _next:)
      @els = req.transcript.elements
      return if last_non_empty_element.nil?
      whitespace = ''
      last_non_empty_element.content = last_non_empty_element.content.gsub(/( +)$/) do |match|
        whitespace = match
        ''
      end
      response_text = _next.call(req)
      last_non_empty_element.content += whitespace unless response_text.start_with?(whitespace)
      response_text
    end

    def last_non_empty_element
      @last_non_empty_element ||= @els.reverse.find { |el| el.content != '' && el.mime == 'text/plain' }
    end

  end
end
