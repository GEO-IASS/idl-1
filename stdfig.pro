;
; Define data to be plotted.
;
x = findgen(101)/10
y1 = sqrt(x)
y2 = x
y3 = x^2
;
; Define some useful colors (color table, ID).
;
black = [0,0]
grey = [0,127]
purple = [34,0]
red = [34,255]
dkblue = [34,31]
green = [8,127]
ltblue = [1,191]
loadct,black[0],/silent
;
; Set plot properties for a single-panel figure, appropriate for one
; column in journal format.
;
csize=1.5
axth=6
pth=6
cth=2

if 1 then begin
!p.thick=pth
!x.thick=axth
!y.thick=axth
!z.thick=axth
!p.charthick=cth
!p.charsize=csize
endif

xyouts,1d90,1d90,'!17 .'

angstrom = '!SA!R!U!9 % !17!N'
sunsymbol = '!9n!X'

xr = [0,10]
yr = [0,100]
pos  = [0.15,0.14,0.97,0.97] ;lbrt
ls = [0,2,1]
col = [0,127,254]

set_plot,'PS' & device,/color,ysize=12.7,xsize=17.8,filename='stdfig-1col.eps',/encapsulated,cmyk=0
plot,[0,0],[0,0],/nodata,xr=xr,yr=yr,pos=pos,xs=5,ys=5
dx = !x.crange[1]-!x.crange[0]
dy = !y.crange[1]-!y.crange[0]

loadct,34,/silent
oplot,x,y1,co=col[0],l=ls[0]
oplot,x,y2,co=col[1],l=ls[1]
oplot,x,y3,co=col[2],l=ls[2]
loadct,0,/silent

plot,[0,0],[0,0],/nodata,xr=xr,yr=yr,pos=pos,xs=1,ys=1,xtitle='!18x!17',ytitle='!18y!17',/noerase

device,/close & set_plot,'X'
;
; Set plot properties for a multi-panel figure, appropriate for two
; columns in journal format.
;
csize=0.8
axth=3
pth=3
cth=1.5

if 1 then begin
!p.thick=pth
!x.thick=axth
!y.thick=axth
!z.thick=axth
!p.charthick=cth
!p.charsize=csize
endif

angstrom = '!SA!R!U!9 % !17!N'
sunsymbol = '!9n!X'

xyouts,1d90,1d90,'!17 .'

xsize = 17.8
ysize = 6.2

left = 0.10
rgt = 0.98
xsep = 0.1/xsize
wdt = (rgt-left-2*xsep)/3.
bot = 0.14
top = 0.86

pos = [[left,bot,left+wdt,top],$
       [left+wdt+xsep,bot,rgt-wdt-xsep,top],$
       [rgt-wdt,bot,rgt,top]] ;lbrt

xr = [0,10]
yr = [0,100]
ls = [0,2,1]
col = [0,127,254]

set_plot,'PS' & device,/color,/cmyk,ysize=ysize,xsize=xsize,filename='stdfig-2col.eps',/encapsulated

for i=0,2 do begin
    plot,[0,0],[0,0],/nodata,xr=xr,yr=yr,pos=pos[*,i],xs=5,ys=5,noerase=i
    dx = !x.crange[1]-!x.crange[0]
    dy = !y.crange[1]-!y.crange[0]

    loadct,34,/silent
    oplot,x,y1,co=col[0],l=ls[0]
    oplot,x,y2,co=col[1],l=ls[1]
    oplot,x,y3,co=col[2],l=ls[2]
    loadct,0,/silent

    if i eq 2 then xr2=xr else xr2=0.999*xr
    if i eq 0 then plot,[0,0],[0,0],/nodata,xr=xr2,yr=yr,pos=pos[*,i],xs=1,ys=1,/noerase else plot,[0,0],[0,0],/nodata,xr=xr2,yr=yr,pos=pos[*,i],xs=1,ys=1,/noerase,ytickformat='(A1)'

    if i eq 0 then xyouts,-0.15*dx,0.5*dy,'!18y!17',al=0.5,o=90
    if i eq 1 then xyouts,0.5*dx,-0.15*dy,'!18x!17',al=0.5
endfor

device,/close & set_plot,'X'

!p.thick=1
!x.thick=1
!y.thick=1
!z.thick=1
!p.charthick=1
!p.charsize=1

end
