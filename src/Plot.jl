#using Reexport, RecipesBase

#@reexport using Plots



"
Y = βX + ϵ
E(Y|H) = E(βX + ϵ|H) 
       = E(βX|H) + E(ϵ|H) # linearity of E
       = E(βX) + E(ϵ|H) # βX only evaluated  when H
       = βX + E(ϵ|H)
       
E(ϵ|u > -γW) = E(ϵ|u/σ > -γW/σ) # standazilation
            = ρψ(-γW/σ)/(1-Ψ(-γW/σ)) 
            = ρψ(γW/σ)/Ψ(γW/σ)) # pdf of standard normal distribution is symmetry
                                # cdf can be transformed by inverse x-axis 
"