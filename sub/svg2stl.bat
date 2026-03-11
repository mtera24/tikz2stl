@echo off
rem svgからstlを作る
rem %1: 入力ファイル名 (.svg)
rem %2: 出力ファイル名 (.stl)
setlocal

rem %1 が "parts_a.scad" なら、%~n1 は "parts_a" になる
rem openscad -o "%~n1.stl" "%~1"

rem 1番目の引数 (%1) が空かどうかをチェック
if "%~1"=="" goto usage
rem --- メイン処理 ---
rem stl -> scad
rem できたsvgのimport文をscadファイルに追記
copy "template.scad" "%~n1.scad" /y 
rem echo copy "template.scad" "%~n1.scad" /y 
if %ERRORLEVEL% neq 0 (
    echo [ERROR] copyでscadファイルの生成に失敗しました。
    exit /b %ERRORLEVEL%
)
echo [SUCCESS] copyでscadファイルの生成に正常に完了しました。

echo linear_extrude(height=1) import("%~1", center = true, dpi = 960);  >> "%~n1.scad"

rem scad -> stl
echo これからopenSCADでstlに変換します。すこし時間がかかります。
"C:\Program Files\OpenSCAD\openscad.exe" -o "%~n1.stl" "%~n1.scad"
if %ERRORLEVEL% neq 0 (
    echo [ERROR] openSCADでstlファイルの生成に失敗しました。
    exit /b %ERRORLEVEL%
)
echo [SUCCESS] openSCADでstlファイルの生成に正常に完了しました。

goto :eof

:usage
echo ==================================================
echo [使い方]
echo   %~nx0 入力ファイル名(svg)
echo.
echo [説明]
echo   指定したsvgファイルをOpenSCADを使ってstlに変換します。
echo ==================================================
pause
exit /b 1