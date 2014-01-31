module dlife.world;

/**
 *  ライフゲームの世界クラス
 *
 *  ライフゲームのロジック部分を担当する。
 */
class World {

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
     *      x = ライフが存在するか確認する座標
     *      y = ライフが存在するか確認する座標
     *  Returns:
     *      ライフが存在する場合はtrue。そうでなければfalse。
     */
    bool opIndex(size_t x, size_t y) @safe pure
    in {
        assert(x < width);
        assert(y < height);
    } body {
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
        return false;
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

