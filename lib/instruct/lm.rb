require 'erb'

class Instruct::LM
  include Instruct::LM::Variables
  attr_reader :prompts, :last_completion, :completion_model

  def initialize(prompts = [], variables = {}, completion_model: nil)
    @completion_model = completion_model
    initialize_variables(variables)
    @prompts = prompts.dup
    @last_completion = ''
  end

  def f(&block)
    prompt_content = block_given? ? render_template(&block) : raise(ArgumentError, 'Block required')
    Prompt.new(:text, prompt_content)
  end

  def gen(**kwargs)
    partial_output = kwargs.delete(:partial_output) || ''

    # Gather the prompt history up to this point
    prompt_history = prompts.map(&:to_s).join("")
    prompt_history += partial_output
    prompt_history.gsub!(/ +$/,'')
    @completion_model.completion(prompt_history, **kwargs)
  end

  def +(other)
    Instruct::LM.new(@prompts + [other], @variables, completion_model: @completion_model)
  end

  def system(&block)
    prompt_content = block_given? ? render_template(&block) : ''
    Prompt.new(:system, prompt_content)
  end

  def user(text = nil, &block)
    prompt_content = block_given? ? render_template(&block) : text
    Prompt.new(:user, prompt_content)
  end

  def assistant(&block)
    prompt_content = block_given? ? render_template(&block) : ''
    simulate_llm_response(prompt_content)
  end

  def render_template(&block)
    template_str = block.call

    # Create a custom context for the ERB template
    erb_context = Instruct::LM::ERBContext.new(self, block.binding)

    # Create a new ERB template without specifying eoutvar
    erb_template = ERB.new(template_str, trim_mode: '-', eoutvar: '@_erbout')

    # Render the template within the context
    output = erb_template.result(erb_context.instance_eval { binding })

    output
  end

  # Modified select method to simulate an LLM call using prompt history
  def simulate_llm_select(prompt_history, options)
    puts "LLM Prompt:"
    puts prompt_history
    puts "Options: #{options.inspect}"
    # For simulation, pick the first unselected option
    # If all options have been selected, pick a random one
    options.sample
  end

  private

  def simulate_llm_response(prompt_content)
    @last_completion = prompt_content.strip
    @prompts << Prompt.new(:assistant, prompt_content)
  end

  Prompt = Struct.new(:role, :content) do
    def to_s
      return content if role == :text
      "#{role}: #{content}"
    end
  end
end
