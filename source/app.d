module dlife.main;

import derelict.sdl2.sdl;

import dlife.exception;
import dlife.lifegame;

/// モジュール初期化
static this() {
    // SDLライブラリのロード
    DerelictSDL2.load();
}

/**
 *  メイン関数
 */
void main() {
    // SDL初期化
    enforceSdl(SDL_Init(SDL_INIT_EVERYTHING) == 0);
    scope(exit) SDL_Quit();

    // ゲームの実行
    new LifeGame("test", 640, 480, 60).run();
}

