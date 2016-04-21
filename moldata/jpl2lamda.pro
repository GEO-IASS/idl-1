cc = 2.9979246d10 ;c     [cm s^-1]
hck = 1.4387752d0 ;h*c/k [K cm]
;
; Define filenames. Quit if the output file exists.
;
nlev = 26
fin = 'hnc.dat'
fout = 'new.dat'
;jpl = 'JPL/c019003-H217O.cat'
;jpl = 'JPL/c028005-HN13C.cat'
jpl = 'JPL/c028006-H15NC.cat'
if file_test(fout) then begin
    print,'Quitting: output file exists'
    stop
endif
;
; Define format codes.
;
fmtlevin = ''
nqn = 0
if fin eq 'pH2O-H2.dat' or fin eq 'ph2o@daniel.dat' then begin
    fmtlevin = '(I3,F14.6,F7.1,I6,1X,I1,1X,I2)'
    fmtlevout = '(I3,F14.6,F7.1,I6,A1,I1,A1,I-2)'
    fmttrin = '(I4,I5,I4,E12.3,F13.5,F9.1)'
    fmttrout = '(I4,I5,I4,E12.3,F13.5,F9.1)'
    nqn = 3
endif
if fin eq 'oH2O-H2.dat' or fin eq 'oh2o@daniel.dat' then begin
    fmtlevin = '(I3,F13.6,F8.1,I7,1X,I1,1X,I2)'
    fmtlevout = '(I3,F13.6,F8.1,I7,A1,I1,A1,I-2)'
    fmttrin = '(I4,I5,I4,E12.3,F13.5,F9.1)'
    fmttrout = '(I4,I5,I4,E12.3,F13.5,F9.1)'
    nqn = 3
endif
if fin eq 'hnc.dat' then begin
    fmtlevin = '(I5,F16.9,F6.1,I5)'
    fmtlevout = '(I5,F16.9,F6.1,3X,I02)'
    fmttrin = '(I6,I6,I6,E11.3,F21.8,F9.2)'
    fmttrout = '(I6,I6,I6,E11.3,F21.8,F9.2)'
    nqn = 1
endif
;
if fmtlevin eq '' or nqn eq 0 then begin
    print,'Quitting: format codes not set'
    stop
endif
;
; Read in the JPL file.
;
readcol,jpl,d,format='F',/silent
njpl = n_elements(d)
jfreq = dblarr(njpl)
jecm = dblarr(njpl)
jqlo = intarr(njpl,4)
jqup = intarr(njpl,4)
d1=0d0 & d2=0d0 & i1=0 & i2=0 & i3=0 & i4=0 & j1=0 & j2=0 & j3=0 & j4=0
openr,1,jpl
for i=0,njpl-1 do begin
    readf,1,d1,d2,i1,i2,i3,i4,j1,j2,j3,j4,format='(F13.4,18X,F10.4,14X,4(I2),4X,4(I2))'
    jfreq[i] = 1d-3 * d1
    jecm[i] = d2
    jqup[i,*] = [i1,i2,i3,i4]
    jqlo[i,*] = [j1,j2,j3,j4]
endfor
close,1
;
; Read the LAMBDA file. Copy to the new file line by line, replacing
; energies and frequencies with values from JPL.
;
openr,1,fin
openw,2,fout
str=''
i=0
lev=0 & ecm=0d0 & wgt=0d0 & j=0 & kp=0 & km=0
tr=0 & lup=0 & llo=0 & einst=0d0 & freq=0d0 & eup=0d0
qlev = intarr(nlev,nqn)
euplev = dblarr(nlev)
dolev=0 & dotrans=0
while not eof(1) do begin
    readf,1,str,format='(A)'
    if str eq '! NUMBER OF RADIATIVE TRANSITIONS' then dolev=0
    if str eq '! NUMBER OF COLLISION PARTNERS' then dotrans=0
    if str eq '!NUMBER OF COLL PARTNERS' then dotrans=0
;
    if dolev eq 1 then begin
        if nqn eq 1 then begin
            reads,str,lev,ecm,wgt,j,format=fmtlevin
            qlev[lev-1,0] = j
            id = (where(jqlo[*,0] eq j))[0]
            if id eq -1 then begin
                print,'ERROR: level not found'
                print,str
                close,1
                close,2
                stop
            endif
            ecm = jecm[id]
            euplev[lev-1] = ecm*hck
            str = string(lev,ecm,wgt,j,format=fmtlevout)
        endif
        if nqn eq 3 then begin
            reads,str,lev,ecm,wgt,j,kp,km,format=fmtlevin
            qlev[lev-1,*] = [j,kp,km]
            id = (where(jqlo[*,0] eq j and jqlo[*,1] eq kp and jqlo[*,2] eq km and jqlo[*,3] eq 0))[0]
            if id eq -1 then begin
                print,'ERROR: level not found'
                print,str
                close,1
                close,2
                stop
            endif
            ecm = jecm[id]
            euplev[lev-1] = ecm*hck
            str = string(lev,ecm,wgt,j,'_',kp,'_',km,format=fmtlevout)
        endif
    endif
;
    if dotrans eq 1 then begin
        reads,str,tr,lup,llo,einst,freq,eup,format=fmttrin
;        if tr le 22 then print,str
        id = -1
        if nqn eq 1 then begin
            id = (where(jqlo[*,0] eq qlev[llo-1,0] and jqup[*,0] eq qlev[lup-1,0]))[0]
        endif
        if nqn eq 3 then begin
            id = (where(jqlo[*,0] eq qlev[llo-1,0] and jqlo[*,1] eq qlev[llo-1,1] and jqlo[*,2] eq qlev[llo-1,2] and jqlo[*,3] eq 0 and jqup[*,0] eq qlev[lup-1,0] and jqup[*,1] eq qlev[lup-1,1] and jqup[*,2] eq qlev[lup-1,2] and jqup[*,3] eq 0))[0]
        endif
        if id eq -1 then begin
;            print,'ERROR: transition not found:',str
;            close,1
;            close,2
;            stop
            freq = 1d-9*(euplev[lup-1]-euplev[llo-1])*cc/hck
            eup = euplev[lup-1]
        endif else begin
            freq = jfreq[id]
            eup = euplev[lup-1]
        endelse
        str = string(tr,lup,llo,einst,freq,eup,format=fmttrout)
;        if tr le 22 then print,str
    endif
;    
    printf,2,str
    if str eq '! LEVEL + ENERGY(CM-1) + WEIGHT + QUANTUM NOS.  J_K+_K-' then dolev=1
    if str eq '!LEVEL + ENERGIES(cm^-1) + WEIGHT + J' then dolev=1
    if str eq '! TRANS + UP + LOW + EINSTEINA(s^-1) + FREQ(GHz)+ E_up(K)' then dotrans=1
    if str eq '!TRANS + UP + LOW + EINSTEINA(s^-1) + FREQ(GHz) + E_u(K)' then dotrans=1
    i=i+1
endwhile
close,1
close,2
;
;
;
print,''
print,'To do manually:'
print,'- set the new molecule name'
print,'- set the new molecular weight'
print,'- update comment lines'

end
