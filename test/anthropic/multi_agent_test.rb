
require "test_helper"
require "ruby/openai"

# These tests could be flakey as they are based on llm responses
class AnthropicMultiAgentTest < Minitest::Test
  include Instruct::Helpers
  using Instruct::Refinements

  def setup
    self.instruct_default_model = 'claude-3-5-sonnet-latest'
  end

  def test_it_works
    skip
    # Create two agents: Noel Gallagher and an interviewer with a system prompt.
    noel = p{"system: You're Noel Gallagher. Answer questions from an interviewer. Don't end the conversation."}
    interviewer = p{"system: You're a skilled interviewer asking Noel Gallagher questions. Don't end the conversation find new topics."}

    # We start a dynamic Q&A loop with the interviewer by kicking off the
    # interviewing agent and capturing the response under the :reply key.
    interviewer << p{"\nuser: __Noel sits down in front of you.__"} + gen.capture(:reply) + "\n".prompt_safe

    puts interviewer.captured(:reply) # => "Hello Noel, how are you today?"

    2.times do
      # Noel is sent the last value captured in the interviewer's transcript under the :reply key.
      # Similarly, we generate a response for Noel and capture it under the :reply key.
      print "Noel: "
      noel << p{"\nuser: <%= interviewer.captured(:reply) %>"}
      prompt = noel + gen.capture(:reply, list: :replies) + "\n".prompt_safe
      resp = prompt.call do |resp|
        print resp.get_chunk
      end
      print "\n\n"
      noel = prompt + resp


      # Noel's captured reply is now sent to the interviewer, who captures it in the same way.
      prompt = p{"user: <%=  noel.captured(:reply) %>"} + gen.capture(:reply, list: :replies) + "\n".prompt_safe
      interviewer << prompt
      print "Interviewer: "
      print interviewer.captured(:reply)
      print "\n\n"
    end

    # After the conversation, we can access the list captured replies from both agents
    noel_said = noel.captured(:replies).map{ |r| "noel: #{r}" }
    interviewer_said = interviewer.captured(:replies).map{ |r| "interviewer: #{r}" }

    puts noel_said.zip(interviewer_said).flatten.join("\n\n")
    # => "noel: ... \n\n interviewer: ..., ..."
  end
end
