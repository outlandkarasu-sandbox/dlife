module dlife.main;

import derelict.sdl2.sdl;

import dlife.exception;
import dlife.lifegame;

/// ウィンドウの幅
enum WINDOW_WIDTH = 1920;

/// ウィンドウの高さ
enum WINDOW_HEIGHT = 1080;

/// FPS
enum FPS = 60;

/// ウィンドウタイトル
enum WINDOW_TITLE = "dlife";

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
    new LifeGame(WINDOW_TITLE, WINDOW_WIDTH, WINDOW_HEIGHT, FPS).run();
}

