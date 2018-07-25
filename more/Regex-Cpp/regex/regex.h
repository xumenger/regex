#ifndef REGEX_H
#define REGEX_H

#include "bitmap.h"
#include "digraph.h"
#include <assert.h>
#include <ctype.h>
#include <stdlib.h>
#include <algorithm>
#include <limits>
#include <map>
#include <memory>
#include <stack>
#include <string>
#include <stdexcept>
#include <vector>

namespace skl {
struct regex_error : public std::runtime_error
{
    using runtime_error::runtime_error;
};

enum state
{
    state_none = 0,
    state_branch,
    state_char,
    state_repeat,
    state_dot,
    state_match_range,
    state_exclude_range,
    state_capture_begin,
    state_capture_end,
    state_line_start,
    state_line_end,
    state_word_boundary,
    state_not_word_boundary,
    state_predict_begin,
    state_predict_end,
    state_reverse_predict_begin,
    state_reverse_predict_end,
};

struct state_data
{
    // Out state range [out_begin, out_end)
    int out_begin = 0;
    int out_end = 0;
    union
    {
        // Single char
        int c;
        // Repeat data for state_repeat
        struct
        {
            // Repeat begin state
            int repeat_begin;
            // Repeat counter index;
            int index;
            // Repeat [min, max] times
            int min;
            int max;
        };
        // Range data for state_match_range
        // and state_exclude_range
        struct
        {
            // [char_range_begin, char_range_end) index
            int char_range_begin;
            int char_range_end;
        };
        // For state_capture_begin, state_capture_end
        // state_predict_begin, state_reverse_predict_begin
        // The begin and the end pair states have the same
        // capture number, capture_num is the index of capture
        // data
        int capture_num;
    };
};

struct char_range
{
    // Character range [first, last]
    int first;
    int last;

    char_range(int f, int l)
        :first(f), last(l)
    {
    }

    explicit char_range(int c)
        : char_range(c, c)
    {
    }
};

struct states_data
{
    // Data of each state
    std::vector<state_data> data;
    // All character ranges
    std::vector<char_range> char_ranges;
    // Out states
    std::vector<int> out_states;
    // Count of state_repeat
    int repeat_count = 0;
    // Capture count
    int capture_count = 0;

    explicit states_data(std::size_t count)
        :data(count)
    {
    }
};

struct capture
{
    const char *begin;
    const char *end;

    explicit capture(const char *b = nullptr, const char *e = nullptr)
        :begin(b), end(e)
    {
    }

    inline bool is_captured() const
    {
        return begin && end;
    }

    std::string str(const)
    {
        if(is_captured())
            return std::string(begin, end);
        else
            return std::string();
    }

    inline void reset()
    {
        begin = end = nullptr;
    }
};

// Match result of regex match or search
// index of subscript 0 is match result
// captures start from index of subscript 1
class match_result
{
    friend class regex;
public:
    typedef std::vector<capture> captures;
    typedef captures::const_iterator iterator;

    inline const char * start_pos() const
    {
        return captures_[0].begin;
    }

    inline const char * end_pos() const
    {
        return captures_[0].end;
    }

    inline std::size_t size() const
    {
        return captures_size();
    }

    inline const capture & operator [] (std::size_t index) const
    {
        return captures_[index];
    }

    inline iterator begin() const
    {
        return captures_.begin();
    }

    inline iterator end() const
    {
        return captures_.end();
    }

private:
    // All capture data
    captures captures_;
};

// Thread for matching
struct thread
{
    // State index
    int state_index = 0;

    // Previous thread
    thread *prev = nullptr;
    // Next thread
    thread *next = nullptr;

    // For predict states
    capture predict;
    // For reverse predict states
    capture reverse_predict;

    const int repeat_num;
    const int capture_num;

    // Repeat times of all state_repeat
    int *repeat_times;
    // All captures' data
    capture *captures;

    // Reset thread data
    void reset()
    {
        state_index = 0;
        prev = nullptr;
        next = nullptr;
        predict.reset();
        reverse_predict.reset();

        for(int i = 0; i < repeat_num; i++)
            repeat_times[i] = 0;
        for(int i = 0; i < capture_num; i++)
            captures[i].reset();
    }

    // Inherit data from thread t except state_index
    void inherit_from(const thread *t)
    {
        predict = t->predict;
        reverse_predict = t->reverse_predict;

        for(int i = 0; i < repeat_num; i++)
            repeat_times[i] = t->repeat_times[i];
        for(int i = 0; i < capture_num; i++)
            captures[i] = t->captures[i];
    }

    // Split the thread from thread list
    void split()
    {
        prev->next = next;
        next->prev = prev;
        prev = nullptr;
        next = nullptr;
    }

private:
    friend class thread_list;

    thread()
        : repeat_num(0),
          capture_num(0),
          repeat_times(nullptr),
          captures(nullptr)
    {
    }

    thread(int repeat_count, int capture_count)
        : repeat_num(repeat_count),
          capture_num(capture_count),
          repeat_times(new int[repeat_count]()),
          captures(new capture[capture_count])
    {
    }

    thread(const thread &) = delete;
    void operator = (const thread &) = delete;

    ~thread()
    {
        delete [] repeat_times;
        delete [] captures;
    }
};

class thread_list
{
public:
    thread_list() { reset(); }

    thread_list(const thread_list &) = delete;
    void operator = (const thread_list &) = delete;

    ~thread_list()
    {
        auto t = sentry_.next;
        while(t != &sentry_)
        {
            auto tmp = t;
            t = t->next;
            delete tmp;
        }
    }

    inline void reset()
    {
        sentry_.prev = &sentry_;
        sentry_.next = &sentry_;
    }

    inline const thread *tail() const
    {
        return &sentry_;
    }

    // List is empty or not
    inline bool empty() const
    {
        return sentry_.next == &sentry_;
    }

    // Return the first thread in the list
    inline thread * front() const
    {
        return sentry_.next;
    }

    // Push thread t into the front of list, then the list
    // own thread t
    inline void push_front(thread *t)
    {
        t->next = sentry_.next;
        sentry_.next->prev= t;
        sentry_.next = t;
        t->prev = &sentry_;
    }

    // Pop the first thread of list, then the list does not
    // own thread t yet
    inline thread * pop_front()
    {
        assert(!empty());
        auto t = sentry_.next;
        t->split();
        return t;
    }

    // Slice all threads of thread_list tl into the front of
    // the list
    inline void slice(thread_list &tl)
    {
        if(tl.empty())
            return;

        auto p = tl.sentry_.prev;
        p->next = sentry_.next;
        sentry_.next->prev = p;

        auto n = tl.sentry_.next;
        n->prev = &sentry_;
        sentry_.next = n;

        tl.reset();
    }

    // Swap with thread_list tl
    inline void swap(thread_list &tl)
    {
        if(tl.empty() && empty())
            return;

        if(tl.empty())
        {
            tl.slice(*this);
        }
        else if(empty())
        {
            slice(tl);
        }
        else
        {
            thread_list tmp;
            tmp.slice(tl);
            tl.slice(*this);
            slice(tmp);
        }
    }

    // Create thread
    inline static thread *create(int repeat_count, int capture_count)
    {
        return new thread(repeat_count, capture_count);
    }

private:
    thread sentry_;
};

typedef std::vector<std::vector<int>> vertex_extend_states;

// Context data for matching
struct context
{
    // Current match thread
    thread_list tlist;
    // Next match threads
    thread_list next_tlist;
    // Pending threads for generate_tlist
    thread_list pending_tlist;
    // Freed thread list for reuse
    thread_list free_tlist;
    // Current running thead
    thread *current_thread = nullptr;

    // Number of repeat states
    const int repeat_count;
    // Number of capture states
    const int capture_count;

    // Pending states for generate_tlist
    std::vector<std::pair<int, thread*>> pending_states;

    // For epsilon extend pending states
    const vertex_extend_states &epsilon_extend_states;
    bitmap epsilon_bits;

    // Search range [sbegin, send)
    const char *sbegin;
    const char *send;
    // Current searach start position
    const char *spos;
    // Current position
    const char *scur;

    // Has accepted or not
    bool accept = false;
    // Capture when accepted
    std::vector<capture> accept_captures;

    void reset(const char *begin, const char *end)
    {
        free_thread_list(tlist);
        free_thread_list(next_tlist);
        free_thread_list(pending_tlist);
        current_thread = nullptr;
        pending_states.clear();

        sbegin = begin;
        send = end;
        spos = begin;
        scur = begin;
        accept = false;
        accept_captures.clear();
    }

    // Alloc a thread
    inline thread * alloc_thread(bool reset = false)
    {
        if(!free_tlist.empty())
        {
            auto t = free_tlist.pop_front();
            if(reset)
                t->reset();
            return t;
        }

        return thread_list::create(repeat_count, capture_count);
    }

    // Free thread list
    inline void free_thread_list(thread_list &tl)
    {
        free_tlist.slice(tl);
    }

    // Clone thread t and set state index, the put it into pending_threads
    thread * clone_to_pending_threads(const thread *t, int state_index)
    {
    
    }
};
}

#endif
