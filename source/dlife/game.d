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
        // 初期化処理
        initialize();
        scope(exit) finalize();

        // とりあえず待つ
        SDL_Delay(5000);
    }

protected:

    /// 初期化処理
    void initialize() {
        // ウィンドウの生成・表示
        window_ = enforceSdl(SDL_CreateWindow(
                    toStringz(title_),
                    SDL_WINDOWPOS_UNDEFINED,
                    SDL_WINDOWPOS_UNDEFINED,
                    width_,
                    height_,
                    SDL_WINDOW_SHOWN));
    }

    /// 終了処理
    void finalize() {
        // ウィンドウの破棄
        SDL_DestroyWindow(window_);
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
}

