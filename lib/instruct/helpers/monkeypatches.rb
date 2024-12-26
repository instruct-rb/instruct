# This monkeypatch shouldn't have to be used unless
# you can't use refinements (such as in iruby notebooks)
class String
  alias_method :old_concat, :concat
  def <<(other, *args)
    if other.is_a?(Instruct::Prompt) || other.is_a?(Instruct::Prompt::Completion)
    raise Instruct::Error, <<~ERR.chomp
      Consider using become gem here to make string become a prompt, if you see this error you should
      convert your string to an Instruct::Prompt either using Instruct::Prompt.new or "safe string".prompt_safe
      ERR
    else
      old_concat(other, *args)
    end
  end
  alias_method :old_plus, :+
  def +(other)
    if other.is_a?(Instruct::Prompt) || other.is_a?(Instruct::Prompt::Completion)
      (Instruct::Prompt.new(self)) + other
    else
      old_plus(other)
    end
  end

  def prompt_safe
    string = self.is_a?(AttributedString) ? self : Instruct::Prompt.new(self)
    string.add_attrs(safe: true)
  end
end
