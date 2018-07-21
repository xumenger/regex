# 语法类的实现 #to_s 和 Pattern#bracket 方法一起
# 会在必要的时候自动插入()，这样在查看一棵语法树的简单字符表示时，也可以知道它的结构信息
module Pattern
    def bracket(outer_precedence)
        if precedence < outer_precedence
            '(' + to_s + ')'
        else
            to_s
        end
    end

    def inspect
        "/#{self}/"
    end
end


class Empty
    include Pattern

    def to_s
        ''
    end

    def precedence
        3
    end
end


class Literal < Struct.new(:character)
    include Pattern

    def to_s
        character
    end

    def precedence
        3
    end
end


class Concatenate < Struct.new(:first, :second)
    include Pattern

    def to_s
        [first, second].map { |pattern| pattern.bracket(precedence) }.join
    end

    def precedence
        1
    end
end


class Choose < Struct.new(:first, :second)
    include Pattern

    def to_s
        [first, second].map { |pattern| pattern.bracket(precedence) }.join('|')
    end

    def precedence
        0
    end
end


class Repeat < Struct.new(:pattern)
    include Pattern

    def to_s
        pattern.bracket(precedence) + '*'
    end

    def precedence
        2
    end
end
