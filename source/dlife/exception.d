/**
 *  例外関連モジュール
 */
module dlife.exception;

import std.exception;
import std.string;
import std.c.string;

import derelict.sdl2.sdl;

/**
 *  アプリケーション固有例外の基本クラス
 */
class DlifeException : Exception {

    /// コンストラクタ
    pure nothrow @safe this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super(msg, file, line, next);
    }
}

/**
 *  SDLのエラーメッセージの取得
 *
 *  Returns:
 *      SDLのエラーメッセージ。エラーが無ければnull。
 */
@trusted string getSdlMessage() {
    if(auto msg = SDL_GetError()) {
        return msg[0 .. strlen(msg)].idup;
    } else {
        return null;
    }
}

/**
 *  SDLエラー時の例外
 */
class SdlException : DlifeException {

    /// コンストラクタ
    @safe this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super(format("%s SDL message:%s", msg, getSdlMessage()), file, line, next);
    }
}

/**
 *  SDL関数のエラーチェック
 *
 *  Params:
 *      value = SDL関数の戻り値か、エラーチェック結果。
 *      msg = 例外メッセージ。
 *  Returns:
 *      エラーが発生していなければvalue。
 *  Throws:
 *      SdlException エラーが発生していた場合にスローされる。
 */
T enforceSdl(T)(T value, lazy string msg = null) {
    return enforceEx!SdlException(value, msg);
}

