/**
 *  ゲーム本体のモジュール
 */
module dlife.game;

import std.string;

import derelict.sdl2.sdl;

import dlife.exception;

/**
 *  ゲーム本体のクラス
 */
class Game {

    /**
     *  ウィンドウの幅と高さを指定して生成する
     *
     *  Params:
     *      title = ウィンドウタイトル
     *      width = ウィンドウの幅
     *      height = ウィンドウの高さ
     */
    @safe nothrow this(string title, uint width, uint height) {
        title_ = title;
        width_ = width;
        height_ = height;
    }

    /**
     *  ゲームの開始
     */
    void run() {
        // ウィンドウの生成・表示
        window_ = enforceSdl(SDL_CreateWindow(
                    toStringz(title_),
                    SDL_WINDOWPOS_UNDEFINED,
                    SDL_WINDOWPOS_UNDEFINED,
                    width_,
                    height_,
                    SDL_WINDOW_HIDDEN));
        scope(exit) {
            SDL_DestroyWindow(window_);
            window_ = null;
        }

        // レンダラーの生成
        renderer_ = enforceSdl(SDL_CreateRenderer(
                    window_,
                    -1,
                    SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC));
        scope(exit) {
            SDL_DestroyRenderer(renderer_);
            renderer_ = null;
        }

        // レンダラーのクリア
        enforceSdl(SDL_RenderClear(renderer_) == 0);

        // 描画内容の反映
        SDL_RenderPresent(renderer_);

        // ウィンドウの表示
        SDL_ShowWindow(window_);

        // とりあえず待つ
        SDL_Delay(5000);
    }

private:

    /// ウィンドウタイトル
    immutable string title_;

    /// ウィンドウの幅
    immutable uint width_;

    /// ウィンドウの高さ
    immutable uint height_;

    /// ウィンドウ
    SDL_Window* window_;

    /// レンダラー
    SDL_Renderer* renderer_;
}

