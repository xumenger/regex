class FARule < Struct.new(:state, :character, :next_state)
    def applies_to?(state, character)
        self.state == state && self.character == character
    end

    def follow
        next_state
    end

    def inspect
        '#<FARule #{state.inspect} --#{character}--> #{next_state.inspect}>'
    end
end


class DFARulebook < Struct.new(:rules)
    def next_state(state, character)
        rule_for(state, character).follow
    end

    def rule_for(state, character)
        rules.detect { |rule| rule.applies_to?(state, character) }
    end
end


class DFA < Struct.new(:current_state, :accept_states, :rulebook)
    def accepting?
        accept_states.include?(current_state)
    end

    def read_character(character)
        self.current_state = rulebook.next_state(current_state, character)
    end

    def read_string(string)
        string.chars.each do |character|
            read_character(character)
        end
    end
end


print("## test DFARulebook\n")
rulebook = DFARulebook.new([
    FARule.new(1, 'a', 2), FARule.new(1, 'b', 1),
    FARule.new(2, 'a', 2), FARule.new(2, 'b', 3),
    FARule.new(3, 'a', 3), FARule.new(3, 'b', 3)
])
p rulebook.next_state(1, 'a')
p rulebook.next_state(1, 'b')

print("\n## test DFA\n")
p DFA.new(1, [1, 3], rulebook).accepting?
p DFA.new(1, [3], rulebook).accepting?
print("read_character\n")
dfa1 = DFA.new(1, [3], rulebook)
p dfa1.accepting?
dfa1.read_character('b')
p dfa1.accepting?
print("read_string\n")
dfa2 = DFA.new(1, [3], rulebook)
p dfa2.accepting?
dfa2.read_string("aaaaaaaaaaaaab")
p dfa2.accepting?
