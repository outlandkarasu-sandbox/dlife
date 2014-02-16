/**
 *  ライフゲームの実装モジュール
 */
module dlife.lifegame;

import std.random : dice;

import derelict.sdl2.sdl;

import dlife.world : World;
import dlife.game : Game;
import dlife.buffer : Buffer;

/// 初期配置時のライフ生成確率
enum INITIAL_LIFE_PROPORTION = 0.5;

/// 描画時の点バッファサイズ
enum POINT_BUFFER_SIZE = 1000;

/**
 *  ライフゲームの実装
 */
class LifeGame : Game {
    
    /**
     *  ウィンドウの幅と高さを指定して生成する
     *
     *  Params:
     *      title = ウィンドウタイトル
     *      width = ウィンドウの幅
     *      height = ウィンドウの高さ
     *      fps = 秒間フレーム数
     */
    this(string title, uint width, uint height, uint fps ) {
        super(title, width, height, fps);

        // 点バッファの生成
        pointBuffer_ = Buffer!SDL_Point(POINT_BUFFER_SIZE, &drawPoints);

        // ライフゲーム世界の生成
        world_ = new World(width, height);

        // ランダムにライフを配置する
        for(uint y = 0; y < height; ++y) {
            for(uint x = 0; x < width; ++x) {
                if(dice(INITIAL_LIFE_PROPORTION, 1.0 - INITIAL_LIFE_PROPORTION)) {
                    world_.addLife(x, y);
                }
            }
        }
    }

    /**
     *  描画関数
     *
     *  Params:
     *      renderer = 描画用レンダラ
     */
    protected override void draw(SDL_Renderer* renderer) {
        renderer_ = renderer;
        SDL_SetRenderDrawColor(renderer, Uint8.max, Uint8.max, Uint8.max, Uint8.max);
        foreach(x, y; world_) {
            pointBuffer_ ~= SDL_Point(cast(int) x, cast(int) y);
        }

        // 点バッファを描画
        pointBuffer_.flush();

        // 次の時代へ
        world_.next();
    }

private:

    /**
     *  点バッファの描画
     *
     *  Params:
     *      points = 描画する点バッファ
     */
    void drawPoints(const(SDL_Point)[] points) {
        SDL_RenderDrawPoints(
                renderer_, points.ptr, cast(int) points.length);
    }

    /// 描画用レンダラ
    SDL_Renderer* renderer_;

    /// ライフゲーム世界
    World world_;

    /// 座標バッファ
    Buffer!SDL_Point pointBuffer_;
}

