function integrate,x,f,cons=cons,prim=prim
n=n_elements(x)
if keyword_set(prim) then ff=dblarr(n)
if(n_elements(f) ne n) then begin
   print,"Error in function integrate: x and f not equally long"
   stop 
endif
sign=2.d0*(x[n-1] gt x[0])-1.d0
int=0.d0
iact=0
if keyword_set(cons) then begin
   for i=1,n-1 do begin
      int=int+f[i-1]*(x[i]-x[i-1])
      if keyword_set(prim) then ff[i]=int
   endfor
endif else begin
   for i=1,n-1 do begin
      int=int+0.5d0*(f[i]+f[i-1])*(x[i]-x[i-1])
      if keyword_set(prim) then ff[i]=int
   endfor
endelse
if not keyword_set(prim) then return,int*sign else begin
   if x[0] lt x[n-1] then return,ff else return,ff-ff[n-1]
endelse
end
