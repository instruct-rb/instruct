module Instruct
  # This middleware hides the whitespace at the end of the current prompt by
  # adding a chomp_hide attribute to the whitespace with the id of the current
  # request. The prompt_transform then removes the whitespace from the prompt
  #
  # object removes characters marked with chomp_hide for the same request.
  # have the same whitespace at the beginning, the chomp_hide attribute is
  # removed from the prompt. If the response does have the same whitespace
  # it is chomped from the response.
  class ChompMiddleware
    include Instruct::Serializable
    set_instruct_class_id 5

    def call(req, _next:)

      whitespace = ''
      # TODO, this should only be for non-hidden whitespace
      req.prompt.to_s.match(/(\s+)$/) do |match|
        whitespace = match[0]
      end
      range = req.prompt.length - whitespace.length...req.prompt.length

      req.prompt.add_attrs(range, chomped: req.id)
      req.prompt.hide_range_from_prompt(range, by: self.class)


      # TODO: maybe we work out a way to pause the stream from
      # hitting upstream handles until it feels good about it
      trimming_whitespace = true
      unhidden = false
      req.add_stream_handler do |completion, chunk|
        if range.size.positive? && !unhidden
          req.prompt.unhide_range_from_prompt(range, by: self.class)
          unhidden = true
        end
        next completion if !trimming_whitespace
        next false if completion.length < whitespace.length && whitespace.start_with?(completion.to_s)
        # this will stop all upstream handlers, generally not a great idea, but
        # for this middleware it is fine
        if completion.length >= whitespace.length
          trimming_whitespace = false
          if completion.start_with?(whitespace)
            completion[...whitespace.length] = ''
            next false if completion.empty?
          end
        end
        completion
      end

      _next.call(req)

    end


  end
end
