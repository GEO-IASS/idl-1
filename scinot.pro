function scinot,x,d,e

if not keyword_set(e) then e = 0

if x eq 0d0 then begin
   f = '(F'+strcompress(string(d+2,format='(I2)'),/remove_all)+'.'+strcompress(string(d,format='(I2)'),/remove_all)+')'
   a = string(0d0,format=f)
   if e ne 0 then a = a + 'e0' else a = a + '(0)'
endif else begin
   exp = floor(alog10(abs(x)))
   coef = x/10d0^exp
   if coef ge 10d0-0.5d0/10d0^d then begin
      coef = 1d0
      exp = exp + 1
   endif
   f = '(F'+strcompress(string(d+3,format='(I2)'),/remove_all)+'.'+strcompress(string(d,format='(I2)'),/remove_all)+')'
   a = string(coef,format=f)
   case e of
      0: begin
         a = a + '('
      end
      1: begin
         a = a + 'e'
      end
      2: begin
         a = a + '!9X!1710!U'
      end
      else: stop
   endcase
   a = a + strcompress(string(exp,format='(I)'),/remove_all)
   case e of
      0: begin
         a = a + ')'
      end
      1: begin
      end
      2: begin
         a = a + '!N'
      end
      else: stop
   endcase
   a = strcompress(a,/remove_all)
endelse

return,a
end
