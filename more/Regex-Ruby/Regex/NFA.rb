# 为了存储由 #next_states 返回的可能状态，我们使用Ruby 标准库中的Set 类
# 本来我们可以使用Array 类，但Set 类由三个有用的特性
# 1. 它自动去除重复元素  Set[1, 2, 2, 3, 3, 3] 与 Set[1, 2, 3] 等价
# 2. 它不关心元素的顺序  Set[1, 2, 3] 与 Set[1, 3, 2] 等价
# 3. 它提供标准的集合操作，比如交集(#&)、并集(#+) 以及自己测试(#subset?)
require 'set'
require "./FARule.rb"


# 存储NFA 规则的规则手册
# 当我们询问DFA 规则手册处于特定状态的DFA读到一个特定的字符之后下一步应该转到何处时，总会返回一个特定状态
# 但NFA 规则手册需要回答一个不同的问题：在NFA 处于集中可能状态之一是，它读取到一个特定的字符，可能的下一个状态是什么？
class NFARulebook < Struct.new(:rules)
    def next_states(states, character)
        states.flat_map { |state| follow_rules_for(state, character) }.to_set
    end

    def follow_rules_for(state, character)
        rules_for(state, character).map(&:follow)
    end

    def rules_for(state, character)
        rules.select { |rule| rule.applies_to?(state, character) }
    end
end


# 实现一个NFA 类来模拟非确定有限状态自动机
class NFA < Struct.new(:current_states, :accept_states, :rulebook)
    def accepting?
        (current_states & accept_states).any?
    end
end


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
