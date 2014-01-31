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
        auto window = enforceSdl(SDL_CreateWindow(
                    toStringz(title_),
                    SDL_WINDOWPOS_UNDEFINED,
                    SDL_WINDOWPOS_UNDEFINED,
                    width_,
                    height_,
                    SDL_WINDOW_HIDDEN));
        scope(exit) {
            SDL_DestroyWindow(window);
        }

        // レンダラーの生成
        auto renderer = enforceSdl(SDL_CreateRenderer(
                    window,
                    -1,
                    SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC));
        scope(exit) {
            SDL_DestroyRenderer(renderer);
            renderer = null;
        }

        // レンダラーのクリア
        enforceSdl(SDL_RenderClear(renderer) == 0);

        // 描画内容の反映
        SDL_RenderPresent(renderer);

        // ウィンドウの表示
        SDL_ShowWindow(window);

        mainLoop(renderer);
    }

protected:

    /**
     *  メインループ
     *
     *  Params:
     *      renderer = 描画用レンダラ
     */
    void mainLoop(SDL_Renderer* renderer) {
        for(bool quit = false; !quit;) {
            SDL_Event event;
            while(SDL_PollEvent(&event)) {
                quit = !processEvent(event);
            }

            SDL_Delay(300);
        }
    }

    /**
     *  イベント処理
     *
     *  Params:
     *      event = イベント情報
     *  Returns:
     *      処理を続ける場合はtrue。終了する場合はfalse。
     */
    bool processEvent(const ref SDL_Event event) {
        switch(event.type) {
            // マウスボタンクリック。終了する。
            case SDL_MOUSEBUTTONDOWN:
                return false;
            // 終了イベント
            case SDL_QUIT:
                return false;
            // その他。無視する
            default:
                return true;
        }
    }

private:

    /// ウィンドウタイトル
    immutable string title_;

    /// ウィンドウの幅
    immutable uint width_;

    /// ウィンドウの高さ
    immutable uint height_;
}

