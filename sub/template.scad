// template.scad
// これは、figureをとりこむためのテンプレートファイルです。
// 本体バッチファイルにて、コピーされたこのファイルの末尾にsvgのimport文が追加されます。
// --- 変数設定 ---
dia_marker = 5;           // マーカー底面の直径
height_marker = 1;           // マーカーの高さ(半球つぶし後の高さ)
size_base = 150;  // 土台のサイズ
thick_base = 0.3; // 土台の厚み
offset_marker = 10;      // マーカの土台端からの距離 (1cm = 10mm)

scale_figure = 2; // とりこむfigureの拡大率

r = dia_marker / 2;

// --- 1. 土台の作成 ---
color("red")
cube([size_base, size_base, thick_base], true);

// upside/downside marker
// --- 2. マーカー(つぶした半球)の配置 ---
// 左上端からのオフセット計算: Xは右へ、Yは手前へ移動
translate([-(size_base/2) + offset_marker, (size_base/2) - offset_marker, thick_base/2]) 
    scale([1, 1, height_marker/r]) // Z方向に「目標の高さ / 元の半径」の倍率でスケーリング
    difference() {
        sphere(r = r, $fn = 100);
        
        // Zのマイナス側をすべて削って「半球」にする
        translate([-r, -r, -r*2]) 
            cube(r*2);
    }

// figure

scale([scale_figure,scale_figure,1])
