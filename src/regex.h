#ifndef _MINE_REGEX_H_
#define _MINE_REGEX_H_

#include <vector>

/*
 * parser分析正则表达式后产生AST(抽象语法树)
 * ASTNode为AST的基类
 * 提供接口实现Visitor模式访问ASTNode类型
 */

class ASTNode
{
public:
    ACCEPT_VISITOR() = 0;
    virtual ~ASTNode() {}
};

class CharNode : public ASTNode
{
public:
    explicit CharNode(int c): c_(c){}
    ACCEPT_VISITOR();
    int c_;
};

class CharRangeNode: public ASTNode
{
public:
    struct Range
    {
        int first_;
        int last_;

        explicit Range(int first = 0; int last = 0)
        {
        }
    };

    CharRangeNode() {}
    
    void AddRange(int first, int last)
    {
       ranges.push_back(Range(first, last));
    }

    void AddChar(int c)
    {
        chars_.push_back(c);
    }

    ACCEPT_VISITOR();

    std::vector<Range> ranges_;
    std::vector<int> chars_;
};

/*
 * concatenation: abc     match "abc"
 */
class ConcatentationNode: public ASTNode
{
public:
    void AddNode(std::unique_ptr<ASTNode> node)
    {
        nodes_.push_back(std::move(node));
    }

    ACCEPT_VISITOR();

    std::vector<std::unique_ptr<ASTNode>> nodes_;
};

/*
 * alternation: abc|def   match "abc" or "def"
 */
class AlternationNode: public ASTNode
{
public:
    void AddNode(std::unique_ptr<ASTNode> node)
    {
        nodes_.push_back(std::move(node));
    }

    ACCEPT_VISITOR();

    std::vector<std::unique_ptr<ASTNode>> nodes_;
};

/*
 * closure: a*            match "" or "a" or "aa" or "aaa" or "aaa..."
 */
class ClosureNode: public ASTNode
{
public:
    explicit ClosureNode(std::unique_ptr<ASTNode> node)
        :node_(std::move(node))
    {
    
    }

    ACCEPT_VISITOR();

    std::unique_ptr<ASTNode> node_;
}

#endif
