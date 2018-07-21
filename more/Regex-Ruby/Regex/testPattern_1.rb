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

print("\n## test Concatenate\n")
pattern1 = Concatenate.new(Literal.new('a'), Literal.new('b'))
p pattern1.matches?('a')
p pattern1.matches?('ab')
p pattern1.matches?('abc')

print("\n## test Choose\n")
pattern2 = Choose.new(Literal.new('a'), Literal.new('b'))
p pattern2.matches?('a')
p pattern2.matches?('b')
p pattern2.matches?('c')

print("\n## test Repeat\n")
pattern3 = Repeat.new(Literal.new('a'))
p pattern3.matches?('')
p pattern3.matches?('a')
p pattern3.matches?('aa')
p pattern3.matches?('aaa')
