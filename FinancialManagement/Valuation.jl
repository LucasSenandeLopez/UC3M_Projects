include("C:\\Users\\goomb\\OneDrive\\Documentos\\GitHub\\UC3M_Projects\\FinancialManagement\\DCF.jl")
using Main.DCF 
using Plots

const D = 29332000;
const cash = 22927000;
const n_acciones = 2407000;

# Datos sacados del excel en esta misma carpeta
aft_ebit::Vector{Float64} = [11580197.41, 12242822.99, 12852767.51, 13397989.33, 13867194.65, 14250214.58];

amort::Vector{Float64} = [7945742.374, 8400402.341, 8818915.238, 9193018.716, 9514963.541, 9777772.329];

capex::Vector{Float64} = [4836571.28, 5113322.69, 5368071.38, 5595788.06, 5791755.79, 5951727.43];

nwc_change::Vector{Float64} = [27245.53, -634047.17, -583638.18, -521706.92, -448968.94, -366500.64];





rw::Float64 = 0.0661;
g::Float64 = 0.02;

val = noisy_dcf_model(aft_ebit, capex, amort, nwc_change, rw, g);

price = (val - D + cash) / n_acciones;

price_mat::Matrix{Float64} = Matrix{Float64}(undef, (10, 10));

waccs = [0.0661 + 0.01 * i for i in 1:10];
g_rates = [0.03 + 0.0035 * j for j in 1:10];

for col in 1:10 

    for row in 1:10

        price_mat[row, col] = 
            (dcf_model(aft_ebit, capex, amort, nwc_change, waccs[row], g_rates[col]) - D + cash) / n_acciones;

    end

end

#price_mat
println(price)

