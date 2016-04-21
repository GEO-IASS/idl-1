molfile = 'co.dat'
str='' & nlev=0 & nrad=0 & ncoll=0 & ntemp=0
openr,1,molfile
for i=1,5 do readf,1,str
readf,1,nlev
readf,1,str
data = dblarr(4,nlev)
readf,1,data
ecm = reform(data[1,*])         ;cm^-1
weight = reform(data[2,*])
jlev = round(reform(data[3,*]))
readf,1,str
readf,1,nrad
readf,1,str
data = dblarr(6,nrad)
readf,1,data
rlup = round(reform(data[1,*]))
rllo = round(reform(data[2,*]))
einsta = reform(data[3,*])      ;s^-1
freq = reform(data[4,*])        ;GHz
eup = reform(data[5,*])         ;K
for i=1,5 do readf,1,str
readf,1,ncoll
readf,1,str
readf,1,ntemp
readf,1,str
ctemp = dblarr(ntemp)
readf,1,ctemp                   ;K
readf,1,str
rcoll = dblarr(3+ntemp,ncoll)
readf,1,rcoll
clup = round(reform(rcoll[1,*]))
cllo = round(reform(rcoll[2,*]))
rcoll = transpose(rcoll[3:ntemp+2,*]) ;cm^3 s^-1
close,1



temp = 100d0                    ;K
if temp lt min(ctemp) or temp gt max(ctemp) then stop
itemp = max(where(ctemp le temp))
if temp eq max(ctemp) then itemp = ntemp-2
eps = (alog(temp)-alog(ctemp[itemp])) / (alog(ctemp[itemp+1])-alog(ctemp[itemp]))

ncrit = dblarr(nrad)
for i=0,nrad-1 do begin
    icoll = (where(clup eq rlup[i] and cllo eq rllo[i]))[0]
    qul = (1d0-eps)*rcoll[icoll,itemp] + eps*rcoll[icoll,itemp+1]
    ncrit[i] = einsta[i] / qul
    print,rlup[i]-1,rllo[i]-1,freq[i],eup[i],ncrit[i],format='(I2,"-",I2,F10.3,F9.2,E11.3)'
endfor

end
