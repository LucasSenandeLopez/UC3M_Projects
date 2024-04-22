include("C:\\Users\\goomb\\OneDrive\\Documentos\\GitHub\\UC3M_Projects\\FinancialManagement\\DCF.jl")
using Main.DCF 
using Plots
using LaTeXStrings

const D = 29332000;
const cash = 22927000;
const n_acciones = 2407000;

# Datos sacados del excel en esta misma carpeta
aft_ebit::Vector{Float64} = [11580197.41, 12270615.47,12940843.57, 13582975.70, 14189055.92, 14751234.51 ];

amort::Vector{Float64} = [7945742.374, 8419472.12, 8879348.55, 9319946.96, 9735808.37, 10121546.72];

capex::Vector{Float64} = [4836571.28, 5124930.46, 5404857.12, 5673049.25, 5926183.99, 6160982.82];

nwc_change::Vector{Float64} = [27245.53, -660640.98, -641321.80,-614437.58, -579940.56, -537932.36];


rw::Float64 = 0.0902;
g::Float64 = 0.035;

val = noisy_dcf_model(aft_ebit, capex, amort, nwc_change, rw, g);

price = (val - D + cash) / n_acciones;

println("El precio estimado de J&J es: $price")

prices::Matrix{Float64} = Matrix{Float64}(undef, 130, 130);


waccs = [0.0902 + 0.0009 * i for i in -49:80];
g_rates = [0.035 + 0.0001 * i for i in -49:80];

for col in 1:130
    for row in 1:130

        prices[row, col] = 
            (dcf_model(aft_ebit, capex, amort, nwc_change, waccs[row], g_rates[col]) - D + cash) / n_acciones;

    end
end

p_1 = plot(waccs, prices[:, 50], alpha = prices ./ 200.0 , color = :Red , label = "Precio por CCMP", area = true)
title!(L"Análisis de sensibilidad - Precio = $f(r_w)$")
xlabel!("CCMP")
ylabel!("Precio")

p_2 = plot(g_rates, prices[50, :], alpha = prices[50, end:-1:begin] ./ 120.0 , color = :Blue , label = "Precio por crecimiento terminal", area = true)
title!(L"Análisis de sensibilidad - Precio = $f(g)$")
xlabel!("g")
ylabel!("Precio")




p_3 = surface(g_rates, waccs, prices, label = "Análisis de sensibilidad", title = L"Análisis de sensibilidad - Precio = $F(g, r_w)$")
xlabel!("g");
ylabel!("CCMP");

savefig(p_1, "C:\\Users\\goomb\\OneDrive\\Documentos\\GitHub\\UC3M_Projects\\FinancialManagement\\SensitivityWACC.png");

savefig(p_2, "C:\\Users\\goomb\\OneDrive\\Documentos\\GitHub\\UC3M_Projects\\FinancialManagement\\SensitivityGRATE.png");

savefig(p_3, "C:\\Users\\goomb\\OneDrive\\Documentos\\GitHub\\UC3M_Projects\\FinancialManagement\\SensitivityCombined.png");


