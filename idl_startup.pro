device,true_color=24,decomposed=0,retain=2
spawn,'echo $HOST',hostname
homedir='/scratch2/rvisser'
if strpos(hostname,'gondolin') eq 0 then homedir='/usr/Gondolin3/visserr'
