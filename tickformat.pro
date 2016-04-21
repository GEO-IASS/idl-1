function tickformat,axis,index,value

if value lt 1 then begin
    foo = -round(alog10(value))
    bar = '(F'+strcompress(foo+2,/rem)+'.'+strcompress(foo,/rem)+')'
    s = string(value,format=bar)
endif else begin
    foo = round(value)
    s = strcompress(foo,/rem)
endelse

return,s

end
