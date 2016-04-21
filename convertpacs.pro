;
; This function converts an integrated line flux measured with the
; PACS instrument on Herschel into an integrated line intensity.
;
; Author:  Ruud Visser <visserr@umich.edu>
; Date:    13 July 2012
;
; Input:
;   flux:  integrated line flux in erg s^-1 cm^-2
;   wave:  wavelength in micron
;
; Output:
;   tmbdv: integrated line intensity in K km s^-1
;

function convertpacs,flux,wave

if n_elements(flux) ne n_elements(wave) then begin
    print,'ERROR in convertpacs:
    print,'  input parameters must be single values or arrays of the same size'
    print,'Returning value of 0'
    return,0
endif

kk = 1.3806503d-16               ; Boltzmann's constant [erg K^-1]
rad2as = 3600d0*360d0*0.5d0/!dpi ; [arcsec/rad]
spaxel = 9.4d0                   ;PACS spaxel size [arcsec]
dscope = 3.28d0                  ;effective diameter of the Herschel mirror [m]
                                 ;see Roelfsema et al. (2012)

dbeam = 1.22d0 * rad2as * (1d-6*wave) / dscope ;beam diameter [arcsec]
dopp = dbeam / (2d0*sqrt(alog(2d0)))
omega = ((spaxel / (erf(0.5d0*spaxel/dopp))) / rad2as)^2
tmbdv = 1d-6 * flux * (wave*1d-6)^3 / (2d0*(1d-7*kk) * omega)

return,tmbdv

end
