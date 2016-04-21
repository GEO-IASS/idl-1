cc = 2.9979246d10 ;c     [cm s^-1]
hck = 1.4387752d0 ;h*c/k [K cm]
;
; Define filenames. Quit if the output file exists.
;
nlev = 41
fin = 'cn.dat'
fout = 'new.dat'
;cdms = 'CDMS/c027505-13CN.cat'
cdms = 'CDMS/c027506-C15N.cat'
if file_test(fout) then begin
;    print,'Quitting: output file exists'
;    stop
endif
;
; Define format codes.
;
fmtlevin = ''
nqn = 0
if fin eq 'cn.dat' then begin
    fmtlevin = '(I5,F16.8,F9.1,I7,1X,F4.1)'
    fmtlevout = '(I5,F16.8,F9.1,I7,A1,F-4.1)'
    fmttrin = '(I5,I5,I5,E12.3,F17.7,F11.2)'
    fmttrout = '(I5,I5,I5,E12.3,F17.7,F11.2)'
    nqn = 2
endif
;
if fmtlevin eq '' or nqn eq 0 then begin
    print,'Quitting: format codes not set'
    stop
endif
;
; Read in the cdms file.
;
readcol,cdms,d,format='F',/silent
ncdms = n_elements(d)
jfreq = dblarr(ncdms)
jecm = dblarr(ncdms)
jqlo = intarr(ncdms,4)
jqup = intarr(ncdms,4)
d1=0d0 & d2=0d0 & i1=0 & i2=0 & i3=0 & i4=0 & j1=0 & j2=0 & j3=0 & j4=0
openr,1,cdms
for i=0,ncdms-1 do begin
    readf,1,d1,d2,i1,i2,i3,i4,j1,j2,j3,j4,format='(F13.4,18X,F10.4,14X,4(I2),4X,4(I2))'
    jfreq[i] = 1d-3 * d1
    jecm[i] = d2
    jqup[i,*] = [i1,i2,i3,i4]
    jqlo[i,*] = [j1,j2,j3,j4]
endfor
close,1
;
; Read the LAMBDA file. Copy to the new file line by line, replacing
; energies and frequencies with values from cdms.
;
openr,1,fin
openw,2,fout
str=''
i=0
lev=0 & ecm=0d0 & wgt=0d0 & j=0 & kp=0 & km=0 & n=0
tr=0 & lup=0 & llo=0 & einst=0d0 & freq=0d0 & eup=0d0 & jh=0d0
qlev = intarr(nlev,nqn)
euplev = dblarr(nlev)
dolev=0 & dotrans=0
while not eof(1) do begin
    readf,1,str,format='(A)'
    if str eq '! NUMBER OF RADIATIVE TRANSITIONS' then dolev=0
    if str eq '!NUMBER OF RADIATIVE TRANSITIONS' then dolev=0
    if str eq '! NUMBER OF COLLISION PARTNERS' then dotrans=0
    if str eq '!NUMBER OF COLL PARTNERS' then dotrans=0
;
    if dolev eq 1 then begin
        if nqn eq 2 then begin
            reads,str,lev,ecm,wgt,n,jh,format=fmtlevin
            j = round(jh+0.5)
            print,n,jh,j
            qlev[lev-1,*] = [n,j]
            idall = where(jqlo[*,0] eq n and jqlo[*,1] eq j)
            id = (where(jecm[idall] eq min(jecm[idall])))[0]
            id = idall[id]
            if id eq -1 then begin
                print,'ERROR: level not found'
                print,str
                close,1
                close,2
                stop
            endif
            ecm = jecm[id]
            euplev[lev-1] = ecm*hck
            str = string(lev,ecm,wgt,n,'_',jh,format=fmtlevout)
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
        if nqn eq 2 then begin
            id = (where(jqlo[*,0] eq qlev[llo-1,0] and jqlo[*,1] eq qlev[llo-1,1] and jqlo[*,2] eq 0 and jqlo[*,3] eq 1 and jqup[*,0] eq qlev[lup-1,0] and jqup[*,1] eq qlev[lup-1,1] and jqup[*,2] eq 0 and jqup[*,3] eq 1))[0]
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
    if str eq '!LEVEL + ENERGIES(cm^-1) + WEIGHT + QNUM(N_J)' then dolev=1
    if str eq '!LEVEL + ENERGIES(cm^-1) + WEIGHT + J' then dolev=1
    if str eq '! TRANS + UP + LOW + EINSTEINA(s^-1) + FREQ(GHz)+ E_up(K)' then dotrans=1
    if str eq '!TRANS + UP + LOW + EINSTEIN_A[s-1] + FREQ[GHz] + E_u[K]' then dotrans=1
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
