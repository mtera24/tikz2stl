@echo off
rem tikzからstl
rem %1: 入力ファイル名 (.scad)
rem %2: 出力ファイル名 (.stl)
rem %3: 変数 width の値

rem 1番目の引数 (%1) が空かどうかをチェック
if "%~1"=="" goto usage

call tikz2svg.bat %1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] tikz2svgでsvgファイルの生成に失敗しました。
    exit /b %ERRORLEVEL%
)
echo [SUCCESS] tikz2svgでsvgファイルの生成に正常に完了しました。

copy "%~n1_4scad.svg" "%~n1.svg" /y 
call svg2stl.bat "%~n1.svg"
if %ERRORLEVEL% neq 0 (
    echo [ERROR] svg2stlでstlファイルの生成に失敗しました。
    exit /b %ERRORLEVEL%
)
echo [SUCCESS] svg2stlでstlファイルの生成に正常に完了しました。

goto :eof

:usage
echo ==================================================
echo [使い方]
echo   %~nx0 入力ファイル名.tex
echo.
echo [説明]
echo   指定したtexファイルをstl(OpenSCADで)に変換します。
echo ==================================================
pause
exit /b 1