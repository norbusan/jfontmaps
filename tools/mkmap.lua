#! /usr/bin/env texlua

-- '?' は 'Pro' 等に置換される
local foundry = {
   ['noEmbed']   = {
      ml='!Ryumin-Light',
      mr='!Ryumin-Light',
      mb='!Ryumin-Light,Bold',
      gr='!GothicBBB-Medium',
      gru='!GothicBBB-Medium',
      gb='!GothicBBB-Medium,Bold',
      ge='!GothicBBB-Medium,Bold',
      mgr='!GothicBBB-Medium',
      {'n'},
   },
   ['ms']   = {
      noncid = true, 
      ml=':0:msmincho.ttc', mr=':0:msmincho.ttc', mb=':0:msmincho.ttc',
      gr=':0:msgothic.ttc', gru=':0:msgothic.ttc', gb=':0:msgothic.ttc', ge=':0:msgothic.ttc',
      mgr=':0:msgothic.ttc',
      {''},
   },
   ['yu-win']   = {
      noncid = true, 
      ml='yuminl.ttf %!PS YuMincho-Light', 
      mr='yumin.ttf %!PS YuMincho-Regular', 
      mb='yumindb.ttf %!PS YuMincho-DemiBold',
      gr='yugothic.ttf %!PS YuGothic-Regular', 
      gru='yugothic.ttf %!PS YuGothic-Regular', 
      gb='yugothib.ttf %!PS YuGothic-Bold', 
      ge='yugothib.ttf %!PS YuGothic-Bold',
      mgr='yugothib.ttf %!PS YuGothic-Bold',
      {''}, 
   }, 
   ['yu-win10']   = {
      noncid = true, 
      ml='yuminl.ttf %!PS YuMincho-Light', 
      mr='yumin.ttf %!PS YuMincho-Regular', 
      mb='yumindb.ttf %!PS YuMincho-DemiBold',
      gr=':0:YuGothR.ttc %!PS YuGothic-Regular', 
      gru=':0:YuGothM.ttc %!PS YuGothic-Medium', 
      gb=':0:YuGothB.ttc %!PS YuGothic-Bold', 
      ge=':0:YuGothB.ttc %!PS YuGothic-Bold',
      mgr=':0:YuGothB.ttc %!PS YuGothic-Bold',
      {''}, 
   }, 
   ['yu-osx']   = {
      noncid = false, 
      ml='YuMin-Medium.otf', 
      mr='YuMin-Medium.otf', 
      mb='YuMin-Demibold.otf', 
      gr='YuGo-Medium.otf', 
      gru='YuGo-Medium.otf', 
      gb='YuGo-Bold.otf', 
      ge='YuGo-Bold.otf', 
      mgr='YuGo-Bold.otf', 
      {''}, 
   },
   ['ipa']   = {
      noncid = true, 
      ml='ipam.ttf %!PS IPAMincho', 
      mr='ipam.ttf %!PS IPAMincho', 
      mb='ipam.ttf %!PS IPAMincho',
      gr='ipag.ttf %!PS IPAGothic', 
      gru='ipag.ttf %!PS IPAGothic', 
      gb='ipag.ttf %!PS IPAGothic', 
      ge='ipag.ttf %!PS IPAGothic',
      mgr='ipag.ttf %!PS IPAGothic',
      {''},
   },
   ['ipaex']   = {
      noncid = true, 
      ml='ipaexm.ttf %!PS IPAexMincho', 
      mr='ipaexm.ttf %!PS IPAexMincho', 
      mb='ipaexm.ttf %!PS IPAexMincho',
      gr='ipaexg.ttf %!PS IPAexGothic', 
      gru='ipaexg.ttf %!PS IPAexGothic', 
      gb='ipaexg.ttf %!PS IPAexGothic', 
      ge='ipaexg.ttf %!PS IPAexGothic',
      mgr='ipaexg.ttf %!PS IPAexGothic',
      {''},
   },
   ['kozuka']   = {
      ml='KozMin?-Light.otf',
      mr='KozMin?-Regular.otf',
      mb='KozMin?-Bold.otf',
      gr='KozGo?-Regular.otf',
      gru='KozGo?-Medium.otf', 
      gb='KozGo?-Bold.otf',
      ge='KozGo?-Heavy.otf',
      mgr='KozGo?-Heavy.otf',
      {'4','6','6n'}, -- Pro, Pr6 and  Pr6N
   },
   ['morisawa'] = {
      ml='A-OTF-Ryumin?-Light.otf %!PS Ryumin?-Light',
      mr='A-OTF-Ryumin?-Light.otf %!PS Ryumin?-Light',
      mb='A-OTF-FutoMinA101?-Bold.otf %!PS FutoMinA101?-Bold',
      gr='A-OTF-GothicBBB?-Medium.otf %!PS GothicBBB?-Medium',
      gru='A-OTF-GothicBBB?-Medium.otf %!PS GothicBBB?-Medium',
      gb='A-OTF-FutoGoB101?-Bold.otf %!PS FutoGoB101?-Bold',
      ge='A-OTF-MidashiGo?-MB31.otf %!PS MidashiGo?-MB31',
      mgr='A-OTF-Jun101?-Light.otf %!PS Jun101?-Light',
      {'4'}, -- Pro
   },
   ['morisawa-pr6n'] = {
      ml='A-OTF-Ryumin?-Light.otf %!PS Ryumin?-Light',
      mr='A-OTF-Ryumin?-Light.otf %!PS Ryumin?-Light',
      mb='A-OTF-FutoMinA101?-Bold.otf %!PS FutoMinA101?-Bold',
      gr='A-OTF-GothicBBB?-Medium.otf %!PS GothicBBB?-Medium',
      gru='A-OTF-GothicBBB?-Medium.otf %!PS GothicBBB?-Medium',
      gb='A-OTF-FutoGoB101?-Bold.otf %!PS FutoGoB101?-Bold',
      ge='A-OTF-MidashiGo?-MB31.otf %!PS MidashiGo?-MB31',
      mgr='A-OTF-ShinMGo?-Light.otf %!PS ShinMGo?-Light',
      {'6nm'}, -- Pr6N
   },
   ['hiragino'] = {
      ml='HiraMin?-W2.otf',
      mr='HiraMin?-W3.otf',
      mb='HiraMin?-W6.otf',
      gr='HiraKaku?-W3.otf',
      gru='HiraKaku?-W6.otf',
      gb='HiraKaku?-W6.otf',
      ge='HiraKaku?-W8.otf',
      mgr='HiraMaru?-W4.otf',
      {'X','Xn'},  -- Pro and ProN
   },
   ['hiragino-elcapitan'] = {
      ml= 'HiraMin?-W2.otf', -- OSX にはない
      mr= '#1-HiraginoSerif-W3.ttc %!PS HiraMin?-W3',
      mb= '#1-HiraginoSerif-W6.ttc %!PS HiraMin?-W6',
      gr= '#3-HiraginoSans-W3.ttc  %!PS HiraKaku?-W3',
      gru='#3-HiraginoSans-W6.ttc  %!PS HiraKaku?-W6',
      gb= '#3-HiraginoSans-W6.ttc  %!PS HiraKaku?-W6',
      ge= '#2+HiraginoSans-W8.ttc  %!PS HiraKaku?-W8',
      mgr='#0+HiraginoSansR-W4.ttc %!PS HiraMaru?-W4',
      {'X','Xn'},  -- Pro and ProN
   },
}

local suffix = {
   -- { '?' 置換, kanjiEmbed 接尾辞, (ttc index mov)}
   ['']   = {'', ''},          -- 非 CID フォント用ダミー
   ['n']  = {'!', ''},         -- 非埋め込みに使用
   ['4']  = {'Pro', ''},
   ['6']  = {'Pr6', '-pr6'},
   ['X']  = {'Pro', '', '0'},       -- ヒラギノ
   ['Xn'] = {'ProN', '-pron', '1'}, -- ヒラギノ
   ['6n'] = {'Pr6N','-pr6n'},
   ['6nm'] = {'Pr6N',''},      -- モリサワ Pr6N
}

-- '#' は 'h', 'v' に置換される
-- '@' は kanjiEmbed の値に置換される
local maps = {
   ['ptex-@'] = {    -- pTeX 90JIS
      {'rml',  'H', 'mr'},
      {'rmlv', 'V', 'mr'},
      {'gbm',  'H', 'gru'},
      {'gbmv', 'V', 'gru'},
   },
   ['ptex-@-04'] = { -- pTeX JIS04
      {'rml',  '2004-H', 'mr'},
      {'rmlv', '2004-V', 'mr'},
      {'gbm',  '2004-H', 'gru'},
      {'gbmv', '2004-V', 'gru'},
   },
   ['uptex-@'] = {   -- upTeX 90JIS
      {'urml',    'UniJIS-UTF16-H', 'mr'},
      {'urmlv',   'UniJIS-UTF16-V', 'mr'},
      {'ugbm',    'UniJIS-UTF16-H', 'gru'},
      {'ugbmv',   'UniJIS-UTF16-V', 'gru'},
      {'uprml-#', 'UniJIS-UTF16-#', 'mr'},
      {'upgbm-#', 'UniJIS-UTF16-#', 'gru'},
      {'uprml-hq','UniJIS-UCS2-H',  'mr'},
      {'upgbm-hq','UniJIS-UCS2-H',  'gru'},
   },
   ['uptex-@-04'] = { -- upTeX JIS04
      {'urml',    'UniJIS2004-UTF16-H', 'mr'},
      {'urmlv',   'UniJIS2004-UTF16-V', 'mr'},
      {'ugbm',    'UniJIS2004-UTF16-H', 'gru'},
      {'ugbmv',   'UniJIS2004-UTF16-V', 'gru'},
      {'uprml-#', 'UniJIS2004-UTF16-#', 'mr'},
      {'upgbm-#', 'UniJIS2004-UTF16-#', 'gru'},
      {'uprml-hq','UniJIS-UCS2-H',  'mr'},
      {'upgbm-hq','UniJIS-UCS2-H',  'gru'},
   },
   ['otf-@'] = {
      '% TEXT, 90JIS',
      {'hminl-#',  '#', 'ml'},
      {'hminr-#',  '#', 'mr'},
      {'hminb-#',  '#', 'mb'},
      {'hgothr-#', '#', 'gr'},
      {'hgothb-#', '#', 'gb'},
      {'hgotheb-#','#', 'ge'},
      {'hmgothr-#','#', 'mgr'},
      '% TEXT, JIS04',
      {'hminln-#',  '#', 'ml'},
      {'hminrn-#',  '#', 'mr'},
      {'hminbn-#',  '#', 'mb'},
      {'hgothrn-#', '#', 'gr'},
      {'hgothbn-#', '#', 'gb'},
      {'hgothebn-#','#', 'ge'},
      {'hmgothrn-#','#', 'mgr'},
      '% CID',
      {'otf-cjml-#', 'Identity-#',     'ml'},
      {'otf-cjmr-#', 'Identity-#',     'mr'},
      {'otf-cjmb-#', 'Identity-#',     'mb'},
      {'otf-cjgr-#', 'Identity-#',     'gr'},
      {'otf-cjgb-#', 'Identity-#',     'gb'},
      {'otf-cjge-#', 'Identity-#',     'ge'},
      {'otf-cjmgr-#','Identity-#',     'mgr'},
      '% Unicode 90JIS',
      {'otf-ujml-#', 'UniJIS-UTF16-#', 'ml'},
      {'otf-ujmr-#', 'UniJIS-UTF16-#', 'mr'},
      {'otf-ujmb-#', 'UniJIS-UTF16-#', 'mb'},
      {'otf-ujgr-#', 'UniJIS-UTF16-#', 'gr'},
      {'otf-ujgb-#', 'UniJIS-UTF16-#', 'gb'},
      {'otf-ujge-#', 'UniJIS-UTF16-#', 'ge'},
      {'otf-ujmgr-#','UniJIS-UTF16-#', 'mgr'},
      '% Unicode JIS04',
      {'otf-ujmln-#', 'UniJIS2004-UTF16-#', 'ml'},
      {'otf-ujmrn-#', 'UniJIS2004-UTF16-#', 'mr'},
      {'otf-ujmbn-#', 'UniJIS2004-UTF16-#', 'mb'},
      {'otf-ujgrn-#', 'UniJIS2004-UTF16-#', 'gr'},
      {'otf-ujgbn-#', 'UniJIS2004-UTF16-#', 'gb'},
      {'otf-ujgen-#', 'UniJIS2004-UTF16-#', 'ge'},
      {'otf-ujmgrn-#','UniJIS2004-UTF16-#', 'mgr'},
   },
   ['otf-up-@'] = {
      '% TEXT, 90JIS',
      {'uphminl-#',  'UniJIS-UTF16-#', 'ml'},
      {'uphminr-#',  'UniJIS-UTF16-#', 'mr'},
      {'uphminb-#',  'UniJIS-UTF16-#', 'mb'},
      {'uphgothr-#', 'UniJIS-UTF16-#', 'gr'},
      {'uphgothb-#', 'UniJIS-UTF16-#', 'gb'},
      {'uphgotheb-#','UniJIS-UTF16-#', 'ge'},
      {'uphmgothr-#','UniJIS-UTF16-#', 'mgr'},
      '% TEXT, JIS04', 
      {'uphminln-#',  'UniJIS2004-UTF16-#', 'ml'},
      {'uphminrn-#',  'UniJIS2004-UTF16-#', 'mr'},
      {'uphminbn-#',  'UniJIS2004-UTF16-#', 'mb'},
      {'uphgothrn-#', 'UniJIS2004-UTF16-#', 'gr'},
      {'uphgothbn-#', 'UniJIS2004-UTF16-#', 'gb'},
      {'uphgothebn-#','UniJIS2004-UTF16-#', 'ge'},
      {'uphmgothrn-#','UniJIS2004-UTF16-#', 'mgr'},
   },
}

local jis2004_flag = 'n'
local gsub = string.gsub

function string.explode(s, sep)
   local t = {}
   sep = sep or '\n'
   string.gsub(s, "([^"..sep.."]*)"..sep, function(c) t[#t+1]=c end)
   return t
end

local function ret_suffix(fd, s, fa)
   if fd=='kozuka' and s=='6'  then 
      return 'ProVI' -- 小塚だけ特別
   elseif fd:match('hiragino') then
      if string.match(s, jis2004_flag) then
	 return (fa=='ge') and 'StdN' or suffix[s][1]
      else
	 return (fa=='ge') and 'Std'  or suffix[s][1]
      end
      -- ヒラギノ角ゴ W8 は StdN/Std しかない
   else
      return suffix[s][1]
   end
end

local function replace_index(line, s)
   local ttc_mov = suffix[s][3]
   if ttc_mov then
      local ttc_index, ttc_dir = line:match('#(%d)(.)')
      if tonumber(ttc_index) then
	 return line:gsub('#..', ':' .. tostring(tonumber(ttc_index)+tonumber(ttc_dir .. ttc_mov)) .. ':')
      end
   end
   return line
end

local function make_one_line(o, fd, s)
   if type(o) == 'string' then
      return '\n' .. o .. '\n'
   else
      local fx = foundry[fd]
      local fn = replace_index(gsub(fx[o[3]], '?', ret_suffix(fd,s,o[3])), s)
      if fx.noncid and string.match(o[2],'Identity') then
	 if string.match(fn, '%!PS') then
	    fn = gsub(fn, ' %%!PS', '/AJ16 %%!PS')
	 else
	    fn = fn .. '/AJ16'
	 end
      end
      if string.match(o[1], '#') then -- 'H', 'V' 一括出力
	 return gsub(o[1], '#', 'h') .. '\t' .. gsub(o[2], '#', 'H') .. '\t' .. fn .. '\n'
          .. gsub(o[1], '#', 'v') .. '\t' .. gsub(o[2], '#', 'V') .. '\t' .. fn .. '\n'
      else
	 return o[1] .. '\t' .. o[2] .. '\t' .. fn .. '\n'
      end
   end
end

for fd, v1 in pairs(foundry) do
   for _,s in pairs(v1[1]) do
      local dirname = fd .. suffix[s][2]
      print('kanjiEmbed: ' .. dirname)
      -- Linux しか想定していない
      os.execute('mkdir ' .. dirname .. ' &>/dev/null')
      for mnx, mcont in pairs(maps) do
	 --if not string.match(mnx, '-04') or string.match(s, jis2004_flag) then
	 if not string.match(mnx, '-04') or not foundry[fd].noncid then
	    local mapbase = gsub(mnx, '@', dirname)
	    local f = io.open(dirname .. '/' .. mapbase .. '.map', 'w+')
	    for _,x in ipairs(mcont) do
	       f:write(make_one_line(x, fd, s))
	    end
	    if string.match(mapbase,'otf%-hiragino') then
	       print('  hiraprop: ' .. mapbase)
	       local v2 = string.explode([[

% hiraprop
hiramin-w3-h Identity-H $mr
hiramin-w6-h Identity-H $mb
hirakaku-w3-h Identity-H $gr
hirakaku-w6-h Identity-H $gb
hiramaru-w4-h Identity-H $mgr
hiramin-w3-v Identity-V $mr
hiramin-w6-v Identity-V $mb
hirakaku-w3-v Identity-V $gr
hirakaku-w6-v Identity-V $gb
hiramaru-w4-v Identity-V $mgr
]])
	       for i,v in pairs(v2) do
		  v = (v:gsub ('$(%w+)', foundry[fd])):gsub('?', ret_suffix(fd,s,''))
		  v2[i] = replace_index(v, s)
	       end
	       f:write(table.concat(v2, '\n'))
	    end
	    f:close()
	 end
      end
   end
end
