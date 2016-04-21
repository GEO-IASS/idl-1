function sigmoid,x,yshift,height,stiffness,xshift
return,yshift+height/(1d0+exp(-stiffness*(x-xshift)))
end
