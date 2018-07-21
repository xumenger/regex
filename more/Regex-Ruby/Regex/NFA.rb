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

    # 需要一些辅助代码帮助找到从一个特定集合的状态开始，通过自由移动所能到达的所有状态
    def follow_free_moves(states)
        more_states = next_states(states, nil)
        if more_states.subset?(states)
            states
        else
            follow_free_moves(states + more_states)
        end
    end
end


# 实现一个NFA 类来模拟非确定有限状态自动机
class NFA < Struct.new(:current_states, :accept_states, :rulebook)
    def accepting?
        (current_states & accept_states).any?
    end

    def read_character(character)
        self.current_states = rulebook.next_states(current_states, character)
    end

    def read_string(string)
        string.chars.each do |character|
            read_character(character)
        end
    end

    def current_states
        rulebook.follow_free_moves(super)
    end
end


# 就像我们在使用DFA 类时那样，可以很方便地使用一个NFADesign 对象根据需要自动产生一个NFA 实例
# 而不是手工创建它们
class NFADesign < Struct.new(:start_state, :accept_states, :rulebook)
    def accepts?(string)
        to_nfa.tap { |nfa| nfa.read_string(string) }.accepting?
    end

    def to_nfa
        NFA.new(Set[start_state], accept_states, rulebook)
    end
end


