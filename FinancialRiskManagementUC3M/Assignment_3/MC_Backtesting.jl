using Random
using DataFrames
using CSV
using Distributions
using Statistics
using Plots
using LaTeXStrings

Random.seed!(1);

const CONF_LEVEL = 0.95;
const MC_SAMPLES = 50_000;

portfolio_filepath = "C:\\Users\\goomb\\OneDrive\\Documentos\\GitHub\\";
portfolio_filepath *= "UC3M_Projects\\FinancialRiskManagementUC3M\\Data\\Assignment_3\\PortfolioData.csv";

volatility_filepath = "C:\\Users\\goomb\\OneDrive\\Documentos\\GitHub\\";
volatility_filepath *= "UC3M_Projects\\FinancialRiskManagementUC3M\\Data\\Assignment_2\\VolData.csv";

change_filepath = "C:\\Users\\goomb\\OneDrive\\Documentos\\GitHub\\UC3M_Projects\\"
change_filepath *= "FinancialRiskManagementUC3M\\Data\\Assignment_3\\PortfolioChange.csv"

#= 
El compilador mandará un aviso de que estos valores se cambiarán en nueva ejecución 
pero se mantienen como constantes para que sea más rápido acceder a ellos en una función
=#
const portfolio_data = DataFrame(CSV.File(portfolio_filepath, dateformat = "dd/mm/yyyy"));
const volatility_data = DataFrame(CSV.File(volatility_filepath, dateformat = "dd/mm/yyyy"));

portfolio_change = DataFrame(CSV.File(change_filepath, dateformat = "dd/mm/yyyy"))

chol_mat = [[1.         0.         0.         0.         0.        ]
            [0.34992256 0.93677863 0.         0.         0.        ]
            [0.44343552 0.31826043 0.8378993  0.         0.        ]
            [0.58819674 0.17499313 0.1591026  0.77336172 0.        ]
            [0.28496089 0.31751501 0.1701786  0.09910193 0.88272281]];


function normal_simulation()
    
    mat::Matrix{Float32} = Matrix{Float32}(undef, 50_000, 5);
    returns_vector::Vector{Float32} = Vector{Float32}(undef, 50_000)
    var_vector::Vector{Float32} = Vector{Float32}(undef, 6002)

    @inbounds for row in 1:6002

        mat = randn(MC_SAMPLES, 5) * chol_mat .* Vector{Float32}(volatility_data[row, 3:end])';
        returns_vector = mat * Vector{Float32}(portfolio_data[row, 2:end - 1]);

        var_vector[row] = quantile(returns_vector, 1 - CONF_LEVEL);

    end

    return var_vector

end

function student_simulation(ddof::Real)
    
    dist = Distributions.TDist(ddof)

    mat::Matrix{Float32} = Matrix{Float32}(undef, 50_000, 5);
    returns_vector::Vector{Float32} = Vector{Float32}(undef, 50_000)
    var_vector::Vector{Float32} = Vector{Float32}(undef, 6002)

    @inbounds for row in 1:6002

        mat = rand(dist, (MC_SAMPLES, 5)) * chol_mat .* Vector{Float32}(volatility_data[row, 3:end])';
        returns_vector = mat * Vector{Float32}(portfolio_data[row, 2:end - 1]);

        var_vector[row] = quantile(returns_vector, 1 - CONF_LEVEL);

    end

    return var_vector

end

ddof = 6.75
sim_results = student_simulation(ddof)[2:end];

exception_prop = sum(sim_results .> portfolio_change.Change) / 6001;

var_plot = plot(portfolio_change.Date, [sim_results portfolio_change.Change], size = (1000, 500),
    label = ["VaR $(CONF_LEVEL * 100)%" "Actual Change"], alpha = [1.0 0.3], color = [:Red :Blue])
title!(L"VaR by $t(%$ddof)$ Monte Carlo Simulation, exception proportion = %$(round(exception_prop*100, digits = 2))%")

plot_filepath = "C:\\Users\\goomb\\OneDrive\\Documentos\\GitHub\\UC3M_Projects\\"
plot_filepath *= "FinancialRiskManagementUC3M\\Data\\Plots\\Backtesting\\BacktestingVaR_MC_Student_t($ddof).png"

savefig(var_plot, plot_filepath)
