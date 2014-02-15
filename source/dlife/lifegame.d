/**
 *  ライフゲームの実装モジュール
 */
module dlife.lifegame;

import std.random : dice;

import derelict.sdl2.sdl;

import dlife.game : Game;
import dlife.world : World;

/// 初期配置時のライフ生成確率
enum INITIAL_LIFE_PROPORTION = 0.5;

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
        world_ = new World(width, height);
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
        SDL_SetRenderDrawColor(renderer, Uint8.max, Uint8.max, Uint8.max, Uint8.max);
        foreach(x, y; world_) {
            SDL_RenderDrawPoint(renderer, cast(int) x, cast(int) y);
        }

        // 次の時代へ
        world_.next();
    }

private:

    /// ライフゲーム世界
    World world_;
}

