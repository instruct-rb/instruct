module Instruct::Model
  # This middleware hides the whitespace at the end of the current prompt by
  # adding a chomp_hide attribute to the whitespace with the id of the current
  # request. The prompt_transform then removes the whitespace from the prompt
  #
  # object removes characters marked with chomp_hide for the same request.
  # have the same whitespace at the beginning, the chomp_hide attribute is
  # removed from the transcript. If the response does have the same whitespace
  # it is chomped from the response.
  class ChompMiddleware

    def self.filter_chomped_attributes(request_id = nil, attributes)
    end

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
        req.transcript.add_attrs(original_range, chomp_hide: req.id)
      end

      req.add_prompt_transform do | prompt_obj |
        raise RuntimeError, "Chomp Middleware expects prompt obj to be of type TranscriptString" unless prompt_obj.is_a?(Instruct::TranscriptString)

      end
      response = _next.call(req)
      return

      response_text = response.to_s

      unless response_text.start_with?(whitespace)
        ranges_in_original.each do |original_range|
          # TODO: hide on the llm output
          req.transcript.unhide_character_range(original_range, by: self.class)
        end
      end

      response
    end


  end
end
