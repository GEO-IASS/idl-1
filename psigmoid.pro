;par: [yshift,height,stiffness,xshift]
function psigmoid,x,par
return,par[0]+par[1]/(1d0+exp(-par[2]*(x-par[3])))
end
