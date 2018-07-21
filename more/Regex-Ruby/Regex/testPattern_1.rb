require "./Pattern.rb"

print("## 1\n")
pattern = 
    Repeat.new(
        Choose.new(
            Concatenate.new(
                Literal.new('a'),
                Literal.new('b')
            ),
            Literal.new('a')
        )
    )
p pattern.to_s


print("\n## 2\n")
nfa_design1 = Empty.new.to_nfa_design
p nfa_design1.accepts?('')
p nfa_design1.accepts?('a')

nfa_design2 = Literal.new('a').to_nfa_design
p nfa_design2.accepts?('a')
p nfa_design2.accepts?('b')

print("\n## 3\n")
p Empty.new.matches?('a')
p Literal.new('a').matches?('a')
