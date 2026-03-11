@echo off
rem tikzからsvgを作る
rem %1: 入力ファイル名 (.tex)
rem %2: 出力ファイル名 (.svg)
setlocal

rem %1 が "parts_a.scad" なら、%~n1 は "parts_a" になる
rem openscad -o "%~n1.stl" "%~1"

rem 1番目の引数 (%1) が空かどうかをチェック
if "%~1"=="" goto usage
rem --- メイン処理 ---
rem tex -> pdf
platex -interaction=batchmode "%~1" > nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] platexでdviファイルの生成に失敗しました。
    exit /b %ERRORLEVEL%
)
echo [SUCCESS] platexでdviファイルの生成に正常に完了しました。

dvipdfmx "%~n1.dvi"
if %ERRORLEVEL% neq 0 (
    echo [ERROR] dvipdfmxでpdfファイルの生成に失敗しました。
    exit /b %ERRORLEVEL%
)
echo [SUCCESS] dvipdfmxでpdfファイルの生成に正常に完了しました。

rem pdf -> svg
pdftocairo -svg "%~n1.pdf" "%~n1.svg"
if %ERRORLEVEL% neq 0 (
    echo [ERROR] pdftocairoでsvgファイルの生成に失敗しました。
    exit /b %ERRORLEVEL%
)
echo [SUCCESS] pdftocairoでsvgファイルの生成に正常に完了しました。

rem svg -> OpenSCAD対応 svg
py  svg4openscad.py  "%~n1.svg"
if %ERRORLEVEL% neq 0 (
    echo [ERROR] svg4openscad.pyでsvgファイルの変換に失敗しました。
    exit /b %ERRORLEVEL%
)
echo [SUCCESS] svg4openscad.pyでsvgファイルの変換に正常に完了しました。


goto :eof

:usage
echo ==================================================
echo [使い方]
echo   %~nx0 入力ファイル名.tex
echo.
echo [説明]
echo   指定したtexファイルをsvg(OpenSCAD対応)に変換します。
echo ==================================================
pause
exit /b 1