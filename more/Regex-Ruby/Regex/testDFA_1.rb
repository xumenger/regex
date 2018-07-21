require "./DFA.rb"

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

print("\n## test DFADesign\n")
dfa_design = DFADesign.new(1, [3], rulebook)
p dfa_design.accepts?('a')
p dfa_design.accepts?("babababa")
