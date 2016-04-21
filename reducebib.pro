pro reducebib,bibfile,bblfile,newfile

print,'Original .bib file: ',bibfile
print,'.bbl file:          ',bblfile
print,'Reduced .bib file:  ',newfile
;
; Read in the bibitem identifiers from the .bbl file.
;
bibitems = ['']
str = ''
openr,1,bblfile
while not eof(1) do begin
   readf,1,str
   p = strpos(str,']')
   if p ge 0 then begin
      foo = strmid(str,p+1)
      foo = strmid(foo,1,strlen(foo)-2)
      bibitems = [bibitems,foo]
      print,foo
   endif
endwhile
close,1
;
nbib = fix(n_elements(bibitems))-1
bibitems = bibitems[1:nbib]
;
; Find the corresponding entries in the original .bib file
; and write out to the new file.
;
count = 0
openr,1,bibfile
openw,2,newfile
while not eof(1) do begin
   readf,1,str
   if strpos(str,'@') eq 0 then begin
      p = strpos(str,'{')
      foo = strmid(str,p+1)
      foo = strmid(foo,0,strlen(foo)-1)
      if (where(bibitems eq foo))[0] gt -1 then begin
         count = count+1
         printf,2,str
         while not eof(1) do begin
            readf,1,str
            printf,2,str
            if str eq '}' then break
         endwhile
         printf,2,''
      endif
   endif
endwhile
close,2
close,1
;
; Print status.
;
print,'Records found in .bbl:                   ',nbib
print,'Matching records found in original .bib: ',count

if nbib ne count then stop

end
