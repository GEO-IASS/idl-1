cc = 2.9979246d10 ;c     [cm s^-1]
hck = 1.4387752d0 ;h*c/k [K cm]
;
; Define filenames. Quit if the output file exists.
;
fin = 'a-ch3oh.dat'
fout = 'a-ch3oh-reduced.dat'
cutoff = 9999.
;
; Define format codes.
;
fmtlevin = ''
if fin eq 'pH2O-H2.dat' or fin eq 'ph2o@daniel.dat' then begin
    fmtlevin = '(I3,F14.6,F7.1,A)'
    fmtlevout = '(I3,F14.6,F7.1,A)'
    fmttrin = '(I4,I5,I4,E12.3,F13.5,F9.1)'
    fmttrout = '(I4,I5,I4,E12.3,F13.5,F9.1)'
    fmtcollin = '(I4,I4,I3,A)'
    fmtcollout = '(I4,I4,I3,A)'
endif
if fin eq 'oH2O-H2.dat' or fin eq 'oh2o@daniel.dat' then begin
    fmtlevin = '(I3,F13.6,F8.1,A)'
    fmtlevout = '(I3,F13.6,F8.1,A)'
    fmttrin = '(I4,I5,I4,E12.3,F13.5,F9.1)'
    fmttrout = '(I4,I5,I4,E12.3,F13.5,F9.1)'
    fmtcollin = '(I4,I4,I3,A)'
    fmtcollout = '(I4,I4,I3,A)'
endif
if fin eq 'a-ch3oh.dat' then begin
    fmtlevin = '(I5,F16.9,F6.1,A)'
    fmtlevout = '(I5,F16.9,F6.1,A)'
    fmttrin = '(I5,I6,I6,E11.3,F21.8,F9.2)'
    fmttrout = '(I5,I6,I6,E11.3,F21.8,F9.2)'
    fmtcollin = '(I6,I4,I4,A)'
    fmtcollout = '(I6,I4,I4,A)'
endif
;
if fmtlevin eq '' then begin
    print,'Quitting: format codes not set'
    stop
endif
;
; Read the LAMBDA file. Copy to the new file line by line, replacing
; energies and frequencies with values from JPL.
;
ecm2=fltarr(304)
degen=fltarr(304)
openr,1,fin
openw,2,fout
str=''
i=0
lev=0 & ecm=0d0 & wgt=0d0
tr=0 & lup=0 & llo=0 & einst=0d0 & freq=0d0 & eup=0d0 & coll=0 & qn=''
collrates = ''
dolev=0 & dotrans=0 & docoll=0
while not eof(1) do begin
    readf,1,str,format='(A)'
    if str eq '! NUMBER OF RADIATIVE TRANSITIONS' then begin
        nlevnew = ilev
        dolev=0
    endif
    if str eq '! NUMBER OF COLLISION PARTNERS' or str eq '!NUMBER OF COLL PARTNERS' then begin
        ntrnew = itr
        dotrans=0
    endif
    if docoll eq 1 and (str eq '! COLLISION PARTNER' or str eq '!COLLISIONS BETWEEN') then begin
        ncollnew = icoll
        docoll=0
    endif
;
    if dolev eq 1 then begin
        reads,str,lev,ecm,wgt,qn,format=fmtlevin
        ecm2[lev-1] = ecm
        degen[lev-1] = wgt
        if ecm ge cutoff then begin
            continue
        endif else begin
            ilev = ilev+1
        endelse
        str = string(ilev,ecm,wgt,qn,format=fmtlevout)
    endif
;
    if dotrans eq 1 then begin
        reads,str,tr,lup,llo,einst,freq,eup,format=fmttrin
;        if lup gt 52 or llo lt 41 then continue
        if lup gt nlevnew or llo gt nlevnew then begin
            continue
        endif else begin
            itr = itr+1
        endelse
        str = string(itr,lup,llo,einst,freq,eup,format=fmttrout)
    endif
;
    if docoll eq 1 then begin
        reads,str,coll,lup,llo,collrates,format=fmtcollin
;        if lup gt 52 or llo lt 41 then continue
        if lup gt nlevnew or llo gt nlevnew then begin
            continue
        endif else begin
            icoll = icoll+1
        endelse
        str = string(icoll,lup,llo,collrates,format=fmtcollout)
    endif
;    
    printf,2,str
    if str eq '! LEVEL + ENERGY(CM-1) + WEIGHT + QUANTUM NOS.  J_K+_K-' or str eq '!LEVEL + ENERGIES(cm^-1) + WEIGHT + J_k_v' then begin
        dolev=1
        ilev=0
    endif
    if str eq '! TRANS + UP + LOW + EINSTEINA(s^-1) + FREQ(GHz)+ E_up(K)' or str eq '!TRANS + U + L + A(s^-1) + FREQ(GHz) + E_u/k(K)' then begin
        dotrans=1
        itr=0
    endif
    if str eq '! TRANS + UP + LOW + RATE COEFFS(cm^3 s^-1)' or str eq '!TRANS + UP + LOW + COLLRATES(cm^3 s^-1)' then begin
        docoll=1
        icoll=0
    endif
    i=i+1
endwhile
close,1
close,2
;
print,nlevnew,ntrnew,icoll

end
