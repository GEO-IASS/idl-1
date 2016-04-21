@natconst
;molfile = 'c18o.dat'
;molfile = 'ph216o@daniel.dat'
;molfile = 'oh218o@daniel.dat'
;molfile = 'pH2O-H2.dat'
;molfile = 'a-ch3oh.dat'
;molfile = 'ch3cn.dat'
;molfile = 'n2h+@xpol.dat'
molfile = 'n2h+_hfs.dat'
str='' & nlev=0 & ntr=0 & ncoll=0 & ntemp=0
openr,1,molfile
for i=1,5 do readf,1,str
readf,1,nlev
levid = intarr(nlev)
ecm = dblarr(nlev)
weight = dblarr(nlev)
qn = strarr(nlev)
readf,1,str
for i=0,nlev-1 do begin
    readf,1,str
    split = strsplit(str,/ex)
    nsplit = n_elements(split)
    levid[i] = fix(split[0])
    ecm[i] = double(split[1])
    weight[i] = double(split[2])
    qn[i] = strjoin(split[3:nsplit-1],' ')
endfor
readf,1,str
readf,1,ntr
readf,1,str
data = dblarr(6,ntr)
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

ncrit = dblarr(ntr)
for i=0,ntr-1 do begin
;for i=0,10 do begin
;    if freq[i] lt 241.699 or (freq[i] gt 241.888 and freq[i] lt 338.344) or freq[i] gt 338.641 then continue
    if freq[i] gt 2000 then continue
    icoll = (where(clup eq rlup[i] and cllo eq rllo[i]))[0]
    qul = (1d0-eps)*rcoll[icoll,itemp] + eps*rcoll[icoll,itemp+1]
    ncrit[i] = einsta[i] / qul
    qnup = qn[(where(levid eq rlup[i]))[0]]
    qnlo = qn[(where(levid eq rllo[i]))[0]]
    gup = weight[(where(levid eq rlup[i]))[0]]
    print,qnup,qnlo,freq[i],eup[i],gup,einsta[i],ncrit[i],format='(A7," - ",A7,F12.3,F9.2,I4,2(E11.3))'
endfor


;
; Partition function.
;
tex = 100.
z = total(weight*exp(-cc*hh*ecm/kk/tex))
x = weight*exp(-cc*hh*ecm/kk/tex)/z

end
