using Random
using DataFrames
using CSV
using Distributions
using Statistics
using Plots
using LaTeXStrings

#Uncomment this line or set a specific seed if you want fixed results
#Random.seed!(1);

#Parameters of the simulations
const CONF_LEVEL = 0.95;
const MC_SAMPLES = 50_000;

portfolio_filepath = "C:\\Users\\goomb\\OneDrive\\Documentos\\GitHub\\";
portfolio_filepath *= "UC3M_Projects\\FinancialRiskManagementUC3M\\Data\\Assignment_3\\PortfolioData.csv";

volatility_filepath = "C:\\Users\\goomb\\OneDrive\\Documentos\\GitHub\\";
volatility_filepath *= "UC3M_Projects\\FinancialRiskManagementUC3M\\Data\\Assignment_2\\VolData.csv";

change_filepath = "C:\\Users\\goomb\\OneDrive\\Documentos\\GitHub\\UC3M_Projects\\"
change_filepath *= "FinancialRiskManagementUC3M\\Data\\Assignment_3\\PortfolioChange.csv"

#= 
The compiler will throw a warning about changing these values after running the codde for the 2nd+
time. This will not cause any errors and the variables are declared as constants to allow for faster
in-function access to the data    
=#
const portfolio_data = DataFrame(CSV.File(portfolio_filepath, dateformat = "dd/mm/yyyy"));
const volatility_data = DataFrame(CSV.File(volatility_filepath, dateformat = "dd/mm/yyyy"));

portfolio_change = DataFrame(CSV.File(change_filepath, dateformat = "dd/mm/yyyy"))


# Taken from assignment 2; we assume constant correlations
const chol_mat = [[1.         0.         0.         0.         0.        ]
            [0.34992256 0.93677863 0.         0.         0.        ]
            [0.44343552 0.31826043 0.8378993  0.         0.        ]
            [0.58819674 0.17499313 0.1591026  0.77336172 0.        ]
            [0.28496089 0.31751501 0.1701786  0.09910193 0.88272281]];

"""
Runs a N(0,1) MC simulation on portfolio returns for the whole data series; the parameters
of the simulation are MC_SAMPLES and CONF_LEVEL, declared as global constants
"""
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

"""
Runs a t(ddof) MC simulation on portfolio returns for the whole data series; the parameters
of the simulation are MC_SAMPLES and CONF_LEVEL, declared as global constants and ddof, which represents
the degrees of freedom of the Student-t distribution used in the simulation
"""
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
sim_results = student_simulation(ddof)[2:end]; # We take only the values for which actual change is computed

exception_num = sum(sim_results .> portfolio_change.Change);
exception_prop =  exception_num / 6001;

var_plot = plot(portfolio_change.Date, [sim_results portfolio_change.Change], size = (1000, 500),
    label = ["VaR $(CONF_LEVEL * 100)%" "Actual Change"], alpha = [1.0 0.3], color = [:Red :Blue])

title!(L"VaR by $t(%$ddof)$ Monte Carlo Simulation, exception proportion = %$(round(exception_prop*100, digits = 2))%")

#=
Uncomment these lines if you would prefer to see the level of the portfolio value in the plot.
They are currently ommitted for aesthetic reasons.

plot!(twinx(), portfolio_data.portfolio_value[2:end], alpha = 0.4, label = "Portfolio Value", 
    color = :Green, legend = :topright, linewidth = 3);
=#

plot_filepath = "C:\\Users\\goomb\\OneDrive\\Documentos\\GitHub\\UC3M_Projects\\"
plot_filepath *= "FinancialRiskManagementUC3M\\Data\\Plots\\Backtesting\\BacktestingVaR_MC_Student_t($ddof).png"

savefig(var_plot, plot_filepath)




binomial_test = 1 - Distributions.cdf(Distributions.Binomial(6001, 1 - CONF_LEVEL), exception_num - 1)

println("The probability of having $exception_num exceptions or more is $binomial_test
under a Binomial distributions n = 6001, p = $exception_prop")

if (binomial_test < 0.05)
    println("Therefore, the binomial test rejects the model\n");
else
    println("Therefore, the binomial test does not reject the model\n");
end

#=
NOTE: Due to the low proportion and large sample size, the Kupieck Stat does not work properly,
this is implemented only as a proof of conept on how it could work
=#
p = 1 - CONF_LEVEL;

kupieck_statistic = -2*log(((1 - p)^(6001 - exception_num)) * (p^exception_num));
kupieck_statistic += 2*log(((1 - exception_prop)^(6001 - exception_num)) * (exception_prop^exception_num));

crit_value_chisq = quantile(Distributions.Chisq(1), CONF_LEVEL)

println("We have a Kupieck Statistic of $kupieck_statistic, the critical value of its
correspinding χ²(1) distributions is : $crit_value_chisq")
if (kupieck_statistic < crit_value_chisq)
    print("so we reject the model under the Kupieck test");
else
    print("so we cannot reject the model under the Kupieck test");
end

