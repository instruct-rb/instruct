module Instruct
  module Expression
    # This is a deferred expression that when processed renders the ERB template
    # produced by template_block. This block allows for dynamic ERB content, but
    # also lets us capture the local variables in the block at the point of
    # creation. This allows the ERB to both be rendered in the context of the
    # local block variables when it was created, but also include new data from
    # lm[] variables.
    class ERBFuture < Expression
      def initialize(template:, binding:, safe: nil)
        @template = template
        @binding = binding
        @safe = safe
      end

      def safe?
        @safe || true
      end

      def process(lm:, &block)
        @lm = lm
        @block = block
        Instruct::LM::ERBContext.new(erb_future: self, lm: lm, template: @template, _binding: @binding) do |result|
          yield(result)
        end
        @lm = nil
        @block = nil
      end

      # This should create a new LLMFuture and then potentially process it immediately
      def gen(transcript:, **kwargs)
        raise RuntimeError, "#gen can only be called within an ERB template" if @block.nil?
        @lm.gen(transcript: transcript, deferred: false, **kwargs)
      end

      def render_template

        # Create a custom context for the ERB template

        # Create a new ERB template without specifying eoutvar
        compiler = ERB::Compiler.new('-')
        compiler.put_cmd = "@_erbout.<<"
        compiler.insert_cmd = "unsafe_print"
        compiler.pre_cmd = ["@_erbout = +''"]
        compiler.post_cmd = ["@_erbout"]
        # compiler.put_cmd = "unsafe_print"
        src, _, _ = compiler.compile(template_str)

        output = eval(src, erb_context.instance_eval { binding }, '(erb without file)', 0)


        # erb_template = ERB.new(template_str, trim_mode: '-', eoutvar: '@_erbout')
        # compiler = erb_template.make_compiler('-')
        # compiler.put_cmd = "unsafe_print"
        # erb_template.set_eoutvar(compiler, '@_erbout')

        # Render the template within the context
        # output = erb_template.result(erb_context.instance_eval { binding })
        unsafe_split(output, erb_context.unsafe)
      end

      def should_mark_child_plain_text_as_safe?(is_erb_expression)
        @safe || is_erb_expression
      end

      def should_mark_child_llm_future_as_safe?
        @safe || false
      end

    end
  end
end
