/**
 *  汎用的なバッファーのモジュール
 */
module dlife.buffer;

import std.conv : to;
import std.range : chunks;

/**
 *  型Tの値を溜め込み、一杯になった時にflushの処理を行うバッファ
 */
struct Buffer(T) {

    /**
     *  バッファサイズとflush処理を指定して生成する。
     *
     *  Params:
     *      n = バッファサイズ。0より大きい値を指定すること
     *      dg = フラッシュ時の処理
     */
    this(size_t n, void delegate(const(T)[]) dg) @safe
    in {
        assert(n > 0);
    } body {
        buffer_ = new T[n];
        flush_ = dg;
    }

    /**
     *  バッファに値を追加する。
     *  バッファが一杯になった場合、flushを呼び出す。
     *
     *  Params:
     *      values = バッファに追加する値
     */
    void add(const(T)[] values...) {
        // バッファサイズごとに分割
        foreach(chunk; chunks(values, this.length)) {
            auto cap = this.capacity;
            if(cap <= chunk.length) {
                // 残容量を超える場合、残容量分だけ取り込んでflush
                buffer_[end_ .. $] = chunk[0 .. cap];
                end_ += cap;
                flush();
            } else {
                // 残ったデータを取り込む
                buffer_[end_ .. end_ + chunk.length] = chunk;
                end_ += chunk.length;
            }
        }
    }

    /**
     *  バッファに1つ値を追加する。
     *  バッファが一杯になった場合、flushを呼び出す。
     *
     *  Params:
     *      values = バッファに追加する値
     */
    const(T) opOpAssign(string op)(const(T) value) if(op == "~")
    in {
        assert(capacity > 0);
    } body {
        buffer_[end_++] = value;
        if(capacity == 0) {
            flush();
        }
        return value;
    }

    /**
     *  バッファにあるデータを使ってフラッシュ処理を行う。
     *  処理完了後、バッファを空に戻す。
     */
    void flush() {
        flush_(buffer_[0 .. end_]);
        buffer_[] = T.init;
        end_ = 0;
    }

    /**
     *  バッファの合計サイズを返す。
     *
     *  Returns:
     *      バッファの合計サイズ
     */
    @property size_t length() @safe pure nothrow const {
        return buffer_.length;
    }

    /**
     *  バッファの使用済みサイズを返す。
     *
     *  Returns:
     *      バッファの使用済みサイズ
     */
    @property size_t used() @safe pure nothrow const {
        return end_;
    }

    /**
     *  バッファの残り容量を返す。
     *
     *  Returns:
     *      バッファの残り容量
     */
    @property size_t capacity() @safe pure nothrow const {
        return buffer_.length - end_;
    }

private:

    /// バッファ
    T[] buffer_;

    /// フラッシュ時に呼び出すデリゲート
    immutable(void delegate(const(T)[])) flush_;

    /// バッファの現在位置
    size_t end_;
}

// 初期化直後のテスト
unittest {
    auto buffer = Buffer!int(1000, (values){});
    assert(buffer.length == 1000);
    assert(buffer.capacity == 1000);
    assert(buffer.used == 0);
}

// 値の追加のテスト
unittest {
    bool called = false;
    auto buffer = Buffer!int(1000, (values){called = true;});

    // 値を1個追加する
    buffer.add(0);
    assert(buffer.length == 1000);
    assert(buffer.capacity == 999);
    assert(buffer.used == 1);
    assert(!called);
}

// サイズ1のバッファのテスト
unittest {
    const(int)[] calledValues;
    auto buffer = Buffer!int(1, (values){calledValues = values.dup;});

    // 値を1個追加
    buffer.add(0);

    // バッファはflushされている
    assert(buffer.length == 1);
    assert(buffer.capacity == 1);
    assert(buffer.used == 0);

    // 処理が呼び出されている
    assert(calledValues.length == 1);
    assert(calledValues[0] == 0);
}

// サイズ2のバッファのテスト
unittest {
    const(int)[] calledValues;
    auto buffer = Buffer!int(2, (values){calledValues = values.dup;});

    // 値を1個追加
    buffer.add(0);

    // バッファはflushされていない
    assert(buffer.length == 2);
    assert(buffer.capacity == 1);
    assert(buffer.used == 1);

    // 処理は呼び出されていない
    assert(calledValues.length == 0);

    // 値をもう1個追加
    buffer.add(1);

    // バッファはflushされている
    assert(buffer.length == 2);
    assert(buffer.capacity == 2);
    assert(buffer.used == 0);

    // 処理が呼び出されている
    assert(calledValues[] == [0, 1], to!string(calledValues));
}

// サイズ2のバッファの値追加テスト
unittest {
    const(int)[] calledValues;
    auto buffer = Buffer!int(2, (values){calledValues = values.dup;});

    // 値を1個追加
    buffer ~= 0;

    // バッファはflushされていない
    assert(buffer.length == 2);
    assert(buffer.capacity == 1);
    assert(buffer.used == 1);

    // 処理は呼び出されていない
    assert(calledValues.length == 0);

    // 値をもう1個追加
    buffer ~= 1;

    // バッファはflushされている
    assert(buffer.length == 2);
    assert(buffer.capacity == 2);
    assert(buffer.used == 0);

    // 処理が呼び出されている
    assert(calledValues[] == [0, 1], to!string(calledValues));
}

// サイズ2のバッファの複数要素同時追加テスト
unittest {
    const(int)[] calledValues;
    auto buffer = Buffer!int(2, (values){calledValues = values.dup;});

    // 値を2個追加
    buffer.add(0, 1);

    // バッファはflushされている
    assert(buffer.length == 2);
    assert(buffer.capacity == 2);
    assert(buffer.used == 0);

    // 処理が呼び出されている
    assert(calledValues[] == [0, 1], to!string(calledValues));

    // 値を３個追加
    buffer.add(3, 2, 1);

    // 1個を残してflushされている
    assert(buffer.length == 2);
    assert(buffer.capacity == 1);
    assert(buffer.used == 1);
    assert(calledValues[] == [3, 2], to!string(calledValues));

    // 強制flush
    buffer.flush();

    assert(buffer.length == 2);
    assert(buffer.capacity == 2);
    assert(buffer.used == 0);
    assert(calledValues[] == [1], to!string(calledValues));
}

