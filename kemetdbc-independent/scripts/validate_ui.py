#!/usr/bin/env python3
"""Build-time smoke checks for the standalone, non-vehicle DBC UI."""
from pathlib import Path
from html.parser import HTMLParser
import json
import re
import subprocess
import tempfile
ROOT=Path(__file__).resolve().parents[1]
HTML=ROOT/'app/src/main/assets/index.html'
s=HTML.read_text(encoding='utf-8')
assert '<html lang="ar" dir="rtl">' in s, 'Arabic default and RTL missing'
assert 'DBCNative.shareText' in s, 'Android export bridge missing'
assert "if(el.dataset.go==='back')navigateBack3()" in s, 'Android back navigation missing'
assert "if(demo3.settings.autoSave)" in s, 'Trip autosave flag missing'
assert 'data-setting="currency"' in s, 'Currency settings missing'
assert "['esim','eSIM PROFILES']" in s, 'eSIM tab missing'
assert "const translations = " in s, 'Language dictionary missing'
class ScriptCollector(HTMLParser):
 def __init__(self):
  super().__init__();self.inside=False;self.out=[]
 def handle_starttag(self,t,a):
  if t=='script':self.inside=True;self.out.append('')
 def handle_endtag(self,t):
  if t=='script':self.inside=False
 def handle_data(self,x):
  if self.inside:self.out[-1]+=x
parser=ScriptCollector();parser.feed(s)
assert len(parser.out)>=2, 'Need app script and localization script'
for i,script in enumerate(parser.out):
 with tempfile.NamedTemporaryFile('w',suffix='.js',encoding='utf8') as f:
  f.write(script);f.flush();p=subprocess.run(['node','--check',f.name],capture_output=True,text=True)
  if p.returncode:raise AssertionError(f'Bad JS script {i}: {p.stderr}')
# Keep these localized labels easy to audit; runtime is tested separately with Playwright.
for ar in ['لوحة القيادة','الطاقة والبطارية','سجل أداء الرحلات','مركز شبكات المودم','الطرفية التشخيصية','البحث في التطبيقات التجريبية','حفظ جميع الإعدادات']:
 assert ar in s, f'Missing localized label {ar}'
print('PASS: Arabic RTL, key screens, native export bridge, back navigation, tab coverage, and JS syntax')