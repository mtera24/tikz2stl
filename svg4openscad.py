# svg4openscad.py
# tikzなど、pdftocairoで生成されたsvgファイルの内容を、
# 文字部分が、openscadの対応してないsymbolで書かれてたので、
# その部分をpathに置き換える。
# usage: svg4openscad <in-file> (out-file)

import argparse
import os # for checking file-exisitence    
import xml.etree.ElementTree as ET
import copy # symbol展開のために必要
import re # 名前空間削除に必要

#fname_input = 'tikzSamples01.svg'

## get arguments
parser = argparse.ArgumentParser()
parser.add_argument('fname_in', type=str, help='original svg file name')
parser.add_argument('fname_out', type=str, nargs='?', default= None,
                   help="modified svg filename for OpenSCAD(optional)")
parser.add_argument("-v", "--verbose", help="increase output verbosity",
                    action="store_true")

args = parser.parse_args() # for command-line version
#args = parser.parse_args(['tikzSamples01_pdftocairo.svg','-v']) # for test in jupyter

## set input / output file
fname_input = args.fname_in
fname_output = args.fname_out

### generate output filename, if not specified
if fname_output==None:
    fname_output = fname_input.split('.svg')[0]+'_4scad'+'.svg'

### verbose report
if args.verbose:
    print("verbosity turned on")
    print(f'Input file : {fname_input}')
    print(f'Output file : {fname_output}')

## main process start
### check file does exist
if not os.path.isfile(fname_input):
    print(f'input file not found: {fname_input}')
    exit(1)

### parse XML tree from file
try:
    tree = ET.parse(fname_input)
except ET.ParseError as e:
    print(f'Error parsing XML: {e} in file{fname_input}')

root = tree.getroot()

#saiyou # 1. symbolの内容をIDごとに取得
symbols = {}
for symbol in root.iter('{http://www.w3.org/2000/svg}symbol'):
    symbol_id = symbol.get('id')
    if symbol_id:
        # symbol内の全要素を取得
        symbols[f"#{symbol_id}"] = list(symbol)
        # symbol自体は削除対象にするため親を探して削除（後で一括でも可）

# saiyou kouho
for parent in root.iter():
    for tgtUse in list(parent.findall('{http://www.w3.org/2000/svg}use')):
        href = tgtUse.get('{http://www.w3.org/1999/xlink}href') or tgtUse.get('href')
        #print(href, href in symbols, tgtUse.attrib)
        # 新しいグループ要素を作成
        rplG = ET.Element('{http://www.w3.org/2000/svg}g') # ここのgを変えたほうがよいかも？
        # useのx, yをtransformに変換
        x = tgtUse.get('x', '0')
        y = tgtUse.get('y', '0')
        #print(x,y)
        if x != '0' or y != '0':
            rplG.set('transform', f'translate({x}, {y})') 
         # symbolの中身をコピーして追加
        for item in symbols[href]:
            rplG.append(copy.deepcopy(item))
        # useと入れ替え
        parent.append(rplG)
        parent.remove(tgtUse) # わかりにくければ、削除しなくてよい(openSCAD側で無視されるため、あっても影響はない)            

m = re.match(r'\{.*\}', root.tag)
#print(m)

ns_url = m.group(0)[1:-1] if m else None
#print(ns_url)

# saiyou
ET.register_namespace('',ns_url)

#saiyou
# 保存
tree.write(fname_output,
           encoding='utf-8',
           xml_declaration=True)