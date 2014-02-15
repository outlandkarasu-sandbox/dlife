module dlife.world;

import std.typetuple : TypeTuple;

/**
 *  ライフゲームの世界クラス
 *
 *  ライフゲームのロジック部分を担当する。
 */
class World {

    enum {
        SURVIVE_COUNT = 2, /// ライフが生き残る数
        BIRTH_COUNT = 3    /// ライフが誕生する数
    }

    /**
     *  世界の幅と高さを指定して生成する
     *
     *  Params:
     *      width = 世界の幅
     *      height = 世界の高さ
     */
    this(size_t width, size_t height) @safe pure {
        width_ = width;
        height_ = height;

        initializeWorld(world1_);
        initializeWorld(world2_);
        currentWorld_ = world1_;
    }

    /**
     *  世界の幅を返す
     *
     *  Returns:
     *      世界の幅
     */
    @property size_t width() @safe pure nothrow {
        return width_;
    }

    /**
     *  世界の高さを返す
     *
     *  Returns:
     *      世界の高さ
     */
    @property size_t height() @safe pure nothrow {
        return height_;
    }

    /**
     *  ライフを指定座標に追加する
     *
     *  Params:
     *      x = ライフを追加する座標
     *      y = ライフを追加する座標
     */
    void addLife(size_t x, size_t y) @safe
    in {
        assert(x < width);
        assert(y < height);
    } body {
        currentWorld_[y][x] = true;
    }

    /**
     *  指定座標にライフが存在するか返す
     *
     *  Params:
     *      x = ライフが存在するか確認する座標。世界のサイズを超える場合は折り返し。
     *      y = ライフが存在するか確認する座標。世界のサイズを超える場合は折り返し。
     *  Returns:
     *      ライフが存在する場合はtrue。そうでなければfalse。
     */
    bool opIndex(size_t x, size_t y) @safe pure {
        return currentWorld_[y][x];
    }

    /// 次の時刻へ進む
    void next() {
        // 全セルについてライフが存在するか計算する
        foreach(y, row; currentWorld_) {
            foreach(x, life; row) {
                nextWorld[y][x] = willSurvive(x, y);
            }
        }

        // 次の時刻の世界に入れ替える
        currentWorld_ = nextWorld;
    }

    /**
     *  指定座標のライフが生き残るかどうか返す
     *
     *  Params:
     *      x = ライフが生き残るかどうか確認する座標
     *      y = ライフが生き残るかどうか確認する座標
     */
    bool willSurvive(size_t x, size_t y) @safe pure
    in {
        assert(x < width);
        assert(y < height);
    } body {
        auto left = (x == 0) ? width - 1 : x - 1;
        auto up = (y == 0) ? height - 1 : y - 1;
        auto right = (x == width - 1) ? 0 : x + 1;
        auto down = (y == height - 1) ? 0 : y + 1;

        auto count = 0;
        foreach(rowIndex; TypeTuple!(up, y, down)) {
            auto row = currentWorld_[rowIndex];
            foreach(colIndex; TypeTuple!(left, x, right)) {
                if(row[colIndex]) {
                    ++count;
                }
            }
        }

        if(currentWorld_[y][x]) {
            --count; // 現在のセルにいるライフは除外する
            return count == SURVIVE_COUNT || count == BIRTH_COUNT;
        } else {
            return count == BIRTH_COUNT;
        }
    }

    /**
     *  生存しているライフを巡回する。
     *
     *  Params:
     *      dg = 生存しているライフを与えられるデリゲート
     */
    int opApply(int delegate(size_t x, size_t y) dg) {
        foreach(y, row; currentWorld_) {
            foreach(x, life; row) {
                if(life) {
                    auto result = dg(x, y);
                    if(result) {
                        return result;
                    }
                }
            }
        }
        return 0;
    }

private:

    /**
     *  世界の初期化
     *
     *  Params:
     *      world = 初期化対象の世界
     */
    void initializeWorld(ref bool[][] world) @safe pure {
        world.length = height_;
        foreach(ref row; world) {
            row.length = width_;
            row[] = false;
        }
    }

    /**
     *  次の世界を返す
     *
     *  Returns:
     *      次の世界
     */
    @property bool[][] nextWorld() @safe pure nothrow {
        return (currentWorld_ is world1_) ? world2_ : world1_;
    }

    /// 現在の世界を表す配列
    bool[][] currentWorld_;

    /// 世界その1
    bool[][] world1_;

    /// 世界その2
    bool[][] world2_;

    /// 世界の幅
    immutable size_t width_;

    /// 世界の高さ
    immutable size_t height_;
}

// 幅と高さのテスト
unittest {
    auto world = new World(100, 200);
    assert(world.width == 100);
    assert(world.height == 200);
}

// ライフの配置と確認のテスト
unittest {
    auto world = new World(100, 100);

    // 配置前は空
    assert(!world[1, 1]);

    // ライフの追加
    world.addLife(1, 1);

    // 配置後は存在する
    assert(world[1, 1]);
}

// 単一のライフの死亡のテスト
unittest {
    auto world = new World(100, 100);

    // ライフ追加
    world.addLife(1, 1);
    assert(world[1, 1]);

    // 次の時刻へ
    world.next();

    // ライフの死亡
    assert(!world[1, 1]);
}

// 固定物体のテスト
unittest {
    auto world = new World(100, 100);

    // ライフ追加
    world.addLife(0, 0);
    world.addLife(0, 1);
    world.addLife(1, 1);
    world.addLife(1, 0);

    // 固定物体の生存
    assert(world[0, 0]);
    assert(world[0, 1]);
    assert(world[1, 1]);
    assert(world[1, 0]);

    world.next();

    // 時刻を進めてもそのまま生存している
    assert(world[0, 0]);
    assert(world[0, 1]);
    assert(world[1, 1]);
    assert(world[1, 0]);
}

// ブリンカーのテスト
unittest {
    auto world = new World(100, 100);

    // 縦向きブリンカー追加
    world.addLife(1, 0);
    world.addLife(1, 1);
    world.addLife(1, 2);

    world.next();

    // 時刻を進めた時は、横向きになっている
    assert(world[0, 1]);
    assert(world[1, 1]);
    assert(world[2, 1]);

    world.next();

    // 次の時刻でまた縦向きになる
    assert(world[1, 0]);
    assert(world[1, 1]);
    assert(world[1, 2]);
}

// 端のブリンカーのテスト
unittest {
    auto world = new World(100, 100);

    // 世界の端に縦向きブリンカー追加
    world.addLife(0, 99);
    world.addLife(0, 0);
    world.addLife(0, 1);

    world.next();

    // 時刻を進めた時は、横向きになっている
    assert(world[99, 0]);
    assert(world[0, 0]);
    assert(world[1, 0]);

    world.next();

    // 次の時刻でまた縦向きになる
    assert(world[0, 99]);
    assert(world[0, 0]);
    assert(world[0, 1]);
}

