import asyncio, pathlib, json, re
from playwright.async_api import async_playwright
PATH=pathlib.Path(__file__).resolve().parent/'app/src/main/assets/index.html'
async def test():
 async with async_playwright() as p:
  browser=await p.chromium.launch(headless=True,executable_path='/usr/bin/chromium',args=['--no-sandbox'])
  page=await browser.new_page(viewport={'width':1280,'height':720})
  errors=[];page.on('pageerror',lambda x:errors.append(str(x)))
  await page.add_init_script('''window.__memory = {};Object.defineProperty(window,'localStorage',{configurable:true,value:{getItem:k=>window.__memory[k]||null,setItem:(k,v)=>{window.__memory[k]=v;},removeItem:k=>delete window.__memory[k]}});''')
  await page.set_content(PATH.read_text(encoding='utf8'))
  assert await page.locator('html').get_attribute('dir')=='rtl'
  assert await page.locator('html').get_attribute('lang')=='ar'
  assert await page.locator('.card').count()==16
  await page.screenshot(path='/mnt/data/DBC_Arabic_1.3.0_Home.png',full_page=True)
  print('main:',await page.locator('#ptitle').inner_text())
  assert 'لوحة القيادة' in await page.locator('#ptitle').inner_text()
  assert 'التاريخ الحالي' in await page.locator('.card').last.inner_text() or 'اليوم' in await page.locator('.card').last.inner_text()
  screens=await page.evaluate('pages.map(x=>x[1])')
  for screen in screens:
   await page.evaluate('(x)=>setpage(x)',screen)
   assert (await page.locator('#main').inner_text()).strip(),screen
   assert await page.locator('html').get_attribute('dir')=='rtl',screen
   if screen=='trip':
    await page.click('#tripSettings');assert 'حفظ جميع الإعدادات' in await page.locator('#main').inner_text()
    await page.screenshot(path='/mnt/data/DBC_Arabic_1.3.0_Trips.png')
    await page.click('#tripLogs');assert 'سجل أداء الرحلات' in await page.locator('#main').inner_text()
    await page.click('#startTrip');assert await page.evaluate('tripDemo')==True
    await page.click('#startTrip');assert await page.evaluate('tripDemo')==False
    assert await page.evaluate('demo3.trips.length')==1
   if screen=='modem':
    tabs=await page.locator('[data-modem]').all_text_contents();assert len(tabs)==3
    for tab in ['local','esim','cloud']:
     await page.locator(f'[data-modem="{tab}"]').click()
     assert (await page.locator('#main').inner_text()).strip(),tab
    await page.screenshot(path='/mnt/data/DBC_Arabic_1.3.0_Modem.png')
   if screen=='settings':
    await page.screenshot(path='/mnt/data/DBC_Arabic_1.3.0_Settings.png')
    await page.locator('#lang3').select_option('en')
    assert await page.locator('html').get_attribute('dir')=='ltr'
    assert 'App Settings' in await page.locator('#ptitle').inner_text()
    assert 'NO VEHICLE LINK' in await page.locator('.top .label').inner_text(), 'English header was not restored'
    await page.locator('#lang3').select_option('ar')
    assert await page.locator('html').get_attribute('dir')=='rtl'
    # Floating preferences and visual theme
    await page.locator('[data-setting="floatingBattery"]').uncheck()
    assert await page.evaluate('demo3.settings.floatingBattery')==False
    await page.locator('[data-setting="floatingBattery"]').check()
    assert await page.evaluate('demo3.settings.floatingBattery')==True
  await page.evaluate("setpage('home')")
  await page.click('#edit');await page.locator('[data-order="0"]').click();await page.locator('[data-order="1"]').click();
  assert await page.evaluate('cards[0][0]')=='ROAMING'
  await page.click('#edit')
  await page.evaluate("setpage('whitelist')")
  await page.locator('#appSearch').fill('Media')
  assert await page.locator('[data-app]').count()==1
  await page.locator('[data-app]').check()
  assert await page.evaluate("demo3.selected['Example Media']") is True
  await page.evaluate("setpage('energy')");await page.evaluate("setpage('settings')")
  await page.evaluate('navigateBack3()')
  assert await page.evaluate('page')=='energy', 'Back stack regression'
  await page.evaluate("setpage('whitelist')")
  await page.locator('#appSearch').fill('<img src=x onerror=alert(1)>')
  assert await page.locator('#appSearch').count()==1
  assert await page.locator('#main img').count()==0, 'Input HTML injection'
  # Localization audit across pages/subtabs
  residual=[]
  for screen in screens:
   await page.evaluate('(x)=>setpage(x)',screen)
   tabs=[None]
   if screen=='trip':tabs=['logs','settings']
   if screen=='modem':tabs=['local','esim','cloud']
   for t in tabs:
    if t:await page.evaluate('(x)=>{if(page===\'trip\')demo3.tab=x;else demo3.modemTab=x;render()}',t)
    bad=await page.evaluate('''() => {const A=[];const w=document.createTreeWalker(document.body,NodeFilter.SHOW_TEXT);while(w.nextNode()){let t=w.currentNode.textContent.trim();if(w.currentNode.parentElement?.tagName==='SCRIPT'||w.currentNode.parentElement?.tagName==='STYLE')continue;
       if(/[A-Za-z]{4,}/.test(t)&& !/^(?:BYD|ADB|KEMET|DBC|MQTT|AUTO|APN|eSIM|SIM|ICCID|IMSI|Shizuku|RAM|OTA|Cloud|SOC|COST|DEMO|kWh|dBm|Mon|Oct|GPS|AEB|Night|Day|CPU|AVM|Wi-Fi|Reference|SIMWorld|Local|HK|Etisalat|Example|Connected|Solar)/i.test(t))A.push(t);}
     return [...new Set(A)];}''')
    if bad:residual.append((screen,t,bad[:10]))
  print('tested screens:',len(screens),'residual:',residual[:20], 'errors:',errors)
  assert not errors,errors
  await browser.close()
asyncio.run(test())