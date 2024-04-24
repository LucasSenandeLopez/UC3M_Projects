using DataFrames
using CSV
using Plots
using Statistics
using LinearAlgebra

close_filepath = "C:\\Users\\goomb\\OneDrive\\Documentos\\GitHub\\UC3M_Projects\\"
close_filepath *= "FinancialRiskManagementUC3M\\Data\\Assignment_2\\CloseData.csv"


portfolio_filepath = "C:\\Users\\goomb\\OneDrive\\Documentos\\GitHub\\UC3M_Projects\\"
portfolio_filepath *= "FinancialRiskManagementUC3M\\Data\\Assignment_3\\PortfolioData.csv"

change_filepath = "C:\\Users\\goomb\\OneDrive\\Documentos\\GitHub\\UC3M_Projects\\"
change_filepath *= "FinancialRiskManagementUC3M\\Data\\Assignment_3\\PortfolioChange.csv"

close_data = DataFrame(CSV.File(close_filepath, dateformat = "dd/mm/yyyy"))

function obtain_daily_change(df_col)
    
    arr = copy(df_col)

    return [log(arr[i]/arr[i-1]) for i in 2:lastindex(arr)]

end



Change_intel = obtain_daily_change(close_data.Close_intel);

Change_exxon = obtain_daily_change(close_data.Close_exxon);

Change_jpmorgan = obtain_daily_change(close_data.Close_jpmorgan);

Change_pfizer = obtain_daily_change(close_data.Close_pfizer);

Change_microsoft = obtain_daily_change(close_data.Close_microsoft);



ch_mat = [Change_intel Change_exxon Change_jpmorgan Change_microsoft Change_pfizer];

portfolio_value = Matrix{Float32}(undef, (lastindex(Change_intel) + 1, 5))

portfolio_value[1, :] = 1_000_000.0 .* [0.2, 0.1, 0.15, 0.35, 0.2]';

portfolio_change = Vector{Float32}(undef, lastindex(Change_intel));

@inbounds for i in 1:lastindex(Change_intel)

    portfolio_value[i + 1, :] = exp.(ch_mat[i, :]) .* portfolio_value[i, :];
    portfolio_change[i] = sum(portfolio_value[i + 1, :]) - sum(portfolio_value[i, :])

end


portfolio_value_col = sum(portfolio_value; dims = 2)


portfolio = DataFrame(:Date => close_data.Date, 
    :Value_intel => portfolio_value[:,1], 
    :Value_exxon => portfolio_value[:, 2],
    :Value_jpmorgan => portfolio_value[:, 3],
    :Value_microsoft => portfolio_value[:, 4],
    :Value_pfizer => portfolio_value[:, 5],
    :portfolio_value => reshape(portfolio_value_col, :))

change_df = DataFrame(:Date => close_data.Date[2:end], :Change => portfolio_change)

CSV.write(portfolio_filepath, portfolio);
CSV.write(change_filepath, change_df);






