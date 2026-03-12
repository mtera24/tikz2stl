@echo off
rem tikzからstl
rem %1: 入力ファイル名 (.tex)

rem 1番目の引数 (%1) が空かどうかをチェック
if "%~1"=="" goto usage

setlocal

rem --- tikz2svg の処理 ---
rem tex -> dvi
platex -interaction=batchmode "%~1" > nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] platexでdviファイルの生成に失敗しました。
    exit /b %ERRORLEVEL%
)
echo [SUCCESS] platexでdviファイルの生成に正常に完了しました。

rem dvi -> pdf
dvipdfmx "%~n1.dvi"  > nul 2>&1
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
py sub\svg4openscad.py "%~n1.svg"
if %ERRORLEVEL% neq 0 (
    echo [ERROR] svg4openscad.pyでsvgファイルの変換に失敗しました。
    exit /b %ERRORLEVEL%
)
echo [SUCCESS] svg4openscad.pyでsvgファイルの変換に正常に完了しました。

rem --- svg2stl の処理 ---
copy "%~n1_4scad.svg" "%~n1.svg" /y > nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] copyでsvgファイルのコピーに失敗しました。
    exit /b %ERRORLEVEL%
)

rem scadファイル作成
copy "sub\template.scad" "%~n1.scad" /y >nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] copyでscadファイルの生成に失敗しました。
    exit /b %ERRORLEVEL%
)
echo [SUCCESS] copyでscadファイルの生成に正常に完了しました。

echo linear_extrude(height=1) import("%~n1.svg", center = true, dpi = 960); >> "%~n1.scad"

rem scad -> stl
echo これからopenSCADでstlに変換します。すこし時間がかかります。
"C:\Program Files\OpenSCAD\openscad.exe" -o "%~n1.stl" "%~n1.scad"  2> nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] openSCADでstlファイルの生成に失敗しました。
    exit /b %ERRORLEVEL%
)
echo [SUCCESS] openSCADでstlファイルの生成に正常に完了しました。

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