require "./NFA.rb"

print("## test NFARulebook\n")
rulebook = NFARulebook.new([
    FARule.new(1, 'a', 1), FARule.new(1, 'b', 1), FARule.new(1, 'b', 2),
    FARule.new(2, 'a', 3), FARule.new(2, 'b', 3),
    FARule.new(3, 'a', 4), FARule.new(3, 'b', 4)
])
p rulebook.next_states(Set[1], 'b')
p rulebook.next_states(Set[1, 2], 'a')

print("\n## test NFA\n")
p NFA.new(Set[1], [4], rulebook).accepting?
p NFA.new(Set[1, 2, 4], [4], rulebook).accepting?
print("test read_string\n")
nfa1 = NFA.new(Set[1], [4], rulebook)
p nfa1.accepting?
nfa1.read_character('b')
p nfa1.accepting?
nfa1.read_character('a')
p nfa1.accepting?
nfa1.read_character('b')
p nfa1.accepting?

print("\n## test NFADesign\n")
nfa_design = NFADesign.new(1, [4], rulebook)
p nfa_design.accepts?('bab')
p nfa_design.accepts?('bbbbb')
p nfa_design.accepts?('bbabb')


print("\ntest rulebook nil\n")
rulebook_nil = NFARulebook.new([
    FARule.new(1, nil, 2), FARule.new(1, nil, 4),
    FARule.new(2, 'a', 3),
    FARule.new(3, 'a', 2),
    FARule.new(4, 'a', 5),
    FARule.new(5, 'a', 6),
    FARule.new(6, 'a', 4)
])
p rulebook_nil.next_states(Set[1], nil)
p rulebook_nil.follow_free_moves(Set[1])

print("\n## test NFA free moves\n")
nfa_design2 = NFADesign.new(1, [2, 4], rulebook_nil)
p nfa_design2.accepts?('aa')
p nfa_design2.accepts?('aaa')

