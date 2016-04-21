function tickfmt10,axis,index,value

foo = round(alog10(value))
s = '10!U'+strcompress(foo,/rem)+'!N'

return,s

end
