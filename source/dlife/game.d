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
     *      fps = 秒間フレーム数
     */
    @safe nothrow this(string title, uint width, uint height, uint fps = 60) {
        title_ = title;
        width_ = width;
        height_ = height;
        fps_ = fps;
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
        }

        // 初期表示
        draw(renderer);

        // ウィンドウの表示
        SDL_ShowWindow(window);

        mainLoop(window, renderer);
    }

protected:

    /**
     *  メインループ
     *
     *  Params:
     *      renderer = 描画用レンダラ
     */
    void draw(SDL_Renderer* renderer) {
        SDL_SetRenderDrawColor(renderer, Uint8.max, Uint8.max, Uint8.max, Uint8.max);
        SDL_RenderDrawPoint(renderer, 100, 100);
    }

    /**
     *  メインループ
     *
     *  Params:
     *      window = メインウィンドウ
     *      renderer = 描画用レンダラ
     */
    void mainLoop(SDL_Window* window, SDL_Renderer* renderer) {
        auto frameTimer = FrameTimer(fps_);

        // イベントを処理し、続行状態である限りフレームを描画する
        for(;;) {
            // フレーム開始
            frameTimer.beginFrame();

            // 全イベント処理
            if(!processAllEvent()) {
                break;
            }

            // 描画のクリア
            SDL_SetRenderDrawColor(renderer, 0, 0, 0, Uint8.max);
            enforceSdl(SDL_RenderClear(renderer) == 0);

            // 画面描画
            draw(renderer);

            // 描画内容の反映
            SDL_RenderPresent(renderer);

            // 次のフレームを待つ
            frameTimer.waitNextFrame();

            // ウィンドウタイトルにFPS表示
            if(frameTimer.frameCount % fps_ == 0) {
                SDL_SetWindowTitle(window, toStringz(format("FPS:%s", frameTimer.fps)));
            }
        }
    }

    /**
     *  受信した全イベントの処理
     *
     *  Returns:
     *      処理続行する場合はtrue。終了する場合はfalse。
     */
    bool processAllEvent() {
        // キューに存在する全イベントを処理する
        for(SDL_Event event; SDL_PollEvent(&event);) {
            if(!processEvent(event)) {
                // イベントループの終了
                return false;
            }
        }

        // イベントループの続行
        return true;
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

    /// 秒間フレーム数
    immutable uint fps_;
}

/**
 *  フレーム描画用タイマー
 */
struct FrameTimer {

    enum MILLS_PER_SECOND = 1000;

    /**
     *  秒間フレーム数を指定して生成
     *
     *  Params:
     *      fps = 秒間フレーム数
     */
    this(uint fps) {
        fps_ = fps;

        // 1フレーム当たりのミリ秒数を求める(端数切り上げ)
        mpf_ = MILLS_PER_SECOND / fps;

        // FPS計測開始
        resetFps();
    }

    /// FPS計測リセット・開始
    void resetFps() {
        fpsBegin_ = SDL_GetTicks();
        frameCount_ = 0;
    }

    /// フレームの開始
    void beginFrame() {
        lastBegin_ = SDL_GetTicks();
    }

    /// 次のフレーム時刻まで待つ
    void waitNextFrame() {
        // フレーム開始時刻と現在時刻から待機時間を算出する
        immutable currentTicks = SDL_GetTicks();
        immutable elapse = currentTicks - lastBegin_;
        if(elapse < mpf_) {
            SDL_Delay(mpf_ - elapse);
        }

        // 次のフレームへ
        lastBegin_ = currentTicks;

        // フレーム描画完了
        ++frameCount_;
    }

    /**
     *  FPS計測開始から現在までのフレーム数を返す
     */
    @property uint frameCount() @safe nothrow pure {
        return frameCount_;
    }

    /**
     *  現在のFPSを返す
     *
     *  Returns:
     *      現在のFPS
     */
    @property double fps() @safe nothrow pure {
        return (cast(double) frameCount_) * MILLS_PER_SECOND / (lastBegin_ - fpsBegin_);
    }

private:

    /// 秒間フレーム数
    immutable uint fps_;

    /// 1フレーム当たりミリ秒数
    immutable uint mpf_;

    /// 直近の開始時刻
    uint lastBegin_;

    /// FPS計測開始時刻
    uint fpsBegin_;

    /// 描画フレーム数
    uint frameCount_;
}

