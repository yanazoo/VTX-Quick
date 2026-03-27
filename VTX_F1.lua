-- VTX_F1.lua  5740 MHz
-- /SCRIPTS/FUNCTIONS/ に置き、スペシャルファンクションで割り当てる

local BAND, CH = "F", 1

local BV={A=1,B=2,E=3,F=4,R=5}
local EA,EL,ER=0xEE,0xEF,0xEA
local PING,DI,PR,RD,WR=0x28,0x29,0x2B,0x2C,0x2D
local LS,LC=1,4
local TP,TE,TW,TS,RM=10,100,15,20,5
local S={PI=1,EN=2,RY=3,WB=4,WC=5,WS=6,CF=7,DN=8}
local v={s=S.PI,di=EA,hi=EL,fc=0,li=0,cb={},ci=0,
         vf=nil,bf=nil,cf=nil,sf=nil,bm=0,bo="",cm=0,t=0,rc=0}

local function push(c,d) if crossfireTelemetryPush then crossfireTelemetryPush(c,d) end end
local function pop()     if crossfireTelemetryPop  then return crossfireTelemetryPop() end end
local function gs(d,i)   local s="" while d[i]and d[i]~=0 do s=s..string.char(d[i]);i=i+1 end return s,i+1 end
local function wp(id,val,ns) push(WR,{v.di,v.hi,id,val});v.s=ns;v.t=getTime() end

-- バンドオプション文字列からバンド名のインデックスを解決
local function bandVal()
  if v.bo~="" then
    local idx=v.bm
    for opt in string.gmatch(v.bo..";","([^;]*);") do
      if opt==BAND then return idx end
      idx=idx+1
    end
  end
  return v.bm+(BV[BAND]or 1)-1  -- フォールバック
end

local rn
local function rf(id) v.li=id;v.cb={};v.ci=0;push(RD,{v.di,v.hi,id,0});v.t=getTime() end
rn=function() if v.vf and v.bf and v.cf and v.sf then v.s=S.RY
              elseif v.li>=v.fc then v.s=S.DN else rf(v.li+1) end end

local function pdi(d)
  if not d or #d<3 or d[2]~=EA then return end
  v.di=d[2];local _,o=gs(d,3);v.fc=(o+12<=#d)and d[o+12]or 0
  if v.fc==0 then v.s=S.DN;return end
  v.s=S.EN;v.li=0;v.vf=nil;v.bf=nil;v.cf=nil;v.sf=nil;v.bo=""
  rn()
end

local function pfd(id,d)
  if type(d)~="table"or #d<3 then return end
  local i=1;local pa=d[i];i=i+1;if pa==0 then pa=nil end
  local ft=d[i]%128;i=i+1;local nm;nm,i=gs(d,i)
  local opts=""
  if ft==9 then opts,i=gs(d,i) end          -- オプション文字列を保存
  local fm=0;if ft<=9 then i=i+1;fm=d[i]or 0;i=i+1 end
  if type(nm)~="string" then return end
  -- VTXフォルダは大文字小文字を問わず検索
  if ft==11 and string.find(string.upper(nm),"VTX") then v.vf=id
  elseif v.vf and pa==v.vf then
    local n=string.lower(nm)
    if     n=="band"  then v.bf=id;v.bm=fm;v.bo=opts  -- オプション保存
    elseif n=="channel" then v.cf=id;v.cm=fm
    elseif string.find(n,"send") or string.find(n,"apply") or string.find(n,"save") then
      v.sf=id
    end
  end
end

local function ppi(d)
  if not d or #d<5 or d[2]~=v.di then return end
  local id,rm=d[3],d[4]
  for i=5,#d do v.cb[#v.cb+1]=d[i] end
  if rm>0 then
    if not v.vf then
      local ft=v.cb[2]and(v.cb[2]%128)or 255
      local nm=gs(v.cb,3)or""
      if not(ft==11 and string.find(string.upper(nm),"VTX"))then rn();return end
    end
    v.ci=v.ci+1;push(RD,{v.di,v.hi,id,v.ci});v.t=getTime();return
  end
  pfd(id,v.cb);rn()
end

local function ca()
  if     v.s==S.WB then wp(v.cf,v.cm+(CH-1),S.WC)
  elseif v.s==S.WC then wp(v.sf,LS,S.WS)
  elseif v.s==S.WS then wp(v.sf,LC,S.CF)
  elseif v.s==S.CF then v.s=S.DN end
end

local function proc()
  for _=1,20 do
    local c,d=pop();if not c then break end
    if c==DI and v.s==S.PI then pdi(d)
    elseif c==PR then
      if v.s==S.EN then ppi(d)
      elseif v.s>=S.WB and v.s<=S.CF then
        local ri=d and d[3]
        local ei=(v.s==S.WB and v.bf)or(v.s==S.WC and v.cf)or v.sf
        if ri==ei then ca() end
      end
    end
  end
  local el=getTime()-v.t
  if v.s==S.PI and el>TP then
    if v.rc<RM then v.rc=v.rc+1;push(PING,{0x00,ER});v.t=getTime()
    else v.s=S.DN end
  elseif v.s==S.EN and el>TE then rf(v.li)
  elseif v.s>=S.WB and v.s<=S.CF and el>((v.s<=S.WC)and TW or TS) then ca()
  end
end

local function init() v.t=getTime();v.s=S.PI;v.rc=0;push(PING,{0x00,ER}) end
local function run()
  if v.s==S.DN then return end
  proc()
  if v.s==S.RY then wp(v.bf,bandVal(),S.WB) end
end

return {init=init,run=run}
