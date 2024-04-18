include("C:\\Users\\goomb\\OneDrive\\Documentos\\GitHub\\UC3M_Projects\\FinancialManagement\\DCF.jl")
using Main.DCF 
using Plots

aft_ebit::Vector{Float64} = [6781.63, 7459.8, 8056.58, 8459.41, 8713.19, 8974.59];
capex::Vector{Float64} = [-9912.16,	5337.02, 4961.43, 3885.27, 3048.39,	1593.12];

amort::Vector{Float64} = [1203.84, 1324.22,	1430.16, 1501.67, 1546.72, 1593.12];
nwc::Vector{Float64} = [267.84,	120.38,	105.94,	71.51,	45.05,	46.40];
rw::Float64 = 0.0661;
g::Float64 = 0.03;

val = dcf_model(aft_ebit, capex, amort, nwc, rw, g);

price = (val - 41_506.00) / 2292.00

price_mat::Matrix{Float64} = Matrix{Float64}(undef, (10, 10));

waccs = [0.0661 + 0.01 * i for i in 1:10];
g_rates = [0.03 + 0.0035 * j for j in 1:10];

for col in 1:10 

    for row in 1:10

        price_mat[row, col] = 
            (dcf_model(aft_ebit, capex, amort, nwc, waccs[row], g_rates[col]) - 41_506.00) / 2292.00

    end

end

price_mat

