import numpy as np;
import pandas as pd;
import matplotlib.pyplot as plt;
import scipy.stats as stats;

plt.style.use("ggplot");

portfolio_change_filepath  = "C:\\Users\\goomb\\OneDrive\\Documentos\\GitHub\\";
portfolio_change_filepath += "UC3M_Projects\\FinancialRiskManagementUC3M\\Data\\Assignment_3\\";

portfolio_value_filepath = portfolio_change_filepath + "PortfolioData.csv";
portfolio_change_filepath += "PortfolioChange.csv";


portfolio_change = pd.read_csv(portfolio_change_filepath, date_format = "dd/mm/yyyy");
portfolio_value = pd.read_csv(portfolio_value_filepath, date_format = "dd/mm/yyyy");

# These global constants allow us to easily change the parameters of the model
BACKTESTING_WINDOW = 1000;
CONF_LEVEL = 0.95;
SERIES_LENGTH = len(portfolio_change.Change);
N = SERIES_LENGTH - BACKTESTING_WINDOW;
P = round(1 - CONF_LEVEL, 4);
PORTFOLIO_VALUES = np.array(portfolio_value.portfolio_value, dtype = "float32");

# Int Conf is only used to simplify plot headers
INT_CONF = round(CONF_LEVEL * 100);

assert ((BACKTESTING_WINDOW < 6001) and (BACKTESTING_WINDOW > 0)), "The time window has to be in [1, 6000]"
assert ((CONF_LEVEL < 1) and (CONF_LEVEL > 0)), "The confidence level must be in (0, 1)"

fig_filepath = "C:\\Users\\goomb\\OneDrive\\Documentos\\GitHub\\UC3M_Projects\\FinancialRiskManagementUC3M";
fig_filepath += "\\Data\\Plots\\Backtesting\\HsVaR";
fig_filepath += f"\\HsVarBacktesting{INT_CONF}CONF{BACKTESTING_WINDOW}SAMPLES.png";

def hist_sim_var(change_arr : np.ndarray, window : int):
    """
    Runs a historic simulation VaR on the array of daily changes that you input using the
    specified time window

    Parameters: Global constant for the confidence level and the values of the portfolio, 
    the specified window and the array of daily changes of the series
    """
    global CONF_LEVEL;
    global PORTFOLIO_VALUES;

    length = len(change_arr);

    result_arr = np.array([np.quantile(change_arr[(i - window):i], 1 - CONF_LEVEL) \
                           for i in range(window, length, 1)], dtype="float32");

    # Because we are using log changes, we have to scale them back
    result_arr = PORTFOLIO_VALUES[(window - 1):-2] * (np.exp(result_arr) - 1); 
    
    return result_arr;




change_arr = np.array(portfolio_change.Change_perc);

absolute_change_arr = np.array(portfolio_change.Change);

var = hist_sim_var(change_arr, BACKTESTING_WINDOW);

n_exceptions = np.sum(absolute_change_arr[BACKTESTING_WINDOW:] < var)
exception_prop = n_exceptions / (len(portfolio_change.Change) - BACKTESTING_WINDOW)

fig, ax = plt.subplots(figsize = (14,8))
plt.plot(portfolio_change.Date[BACKTESTING_WINDOW:], var)
plt.plot(portfolio_change.Date[BACKTESTING_WINDOW:], portfolio_change.Change[BACKTESTING_WINDOW:], \
         label = "Actual change", alpha = 0.3)

ax.set_title(f"{n_exceptions} exceptions from a sample of {N} with a proportion of {round(exception_prop, 4)}")
plt.xticks([portfolio_change.Date[i] for i in range(BACKTESTING_WINDOW, SERIES_LENGTH, 500)])
plt.tick_params(axis='x', labelrotation=45)
plt.legend([f"VaR {round(CONF_LEVEL*100,2)}%","Actual Change"])

plt.savefig(fig_filepath)
plt.show()

plt.clf()






binom_test = 1 - stats.binom.cdf(n_exceptions - 1, SERIES_LENGTH - BACKTESTING_WINDOW, 1 - CONF_LEVEL);

model_message = f"The probability of having {n_exceptions} or more out of {N} samples ";
model_message += f"under a Binom({N}, {P}) is {round(binom_test, 4)}";

print(model_message); 

if binom_test < 0.05:
     
    print("Therefore, we reject the model under the binomial test"); 

else:
     
    print("Thus, we do not have evidence to reject the model under the binomial test");





def window_analysis():
    """
    Runs an analysis on how the binomial test statistic changes with differenf windows
    ranging from 250 to 4000 with a step value of 5
    """

    global CONF_LEVEL;
    global SERIES_LENGTH;
    global INT_CONF;
    global change_arr;
    global absolute_change_arr;

    fig_filepath = "C:\\Users\\goomb\\OneDrive\\Documentos\\GitHub\\UC3M_Projects";
    fig_filepath += f"\\FinancialRiskManagementUC3M\\Data\\Plots\\Backtesting\\HsVar\\HsVaRWindowAnalysis{INT_CONF}.png";

    tests = np.zeros(int((4000 - 250)/5) + 1); #Dimensions + 1 because of 1-based indexing
    wind_sizes = [i for i in range(250, 4000 + 1, 5)];

    for window_size in wind_sizes:

        var = hist_sim_var(change_arr, window_size);

        n_exceptions = np.sum(absolute_change_arr[window_size:] < var) 

        binom_test = 1 - stats.binom.cdf(n_exceptions - 1, SERIES_LENGTH - window_size, 1 - CONF_LEVEL);

        tests[int((window_size - 250)/5)] = binom_test;


    fig, ax = plt.subplots(figsize = (14,8));
    plt.plot(wind_sizes, tests, label = "Test stat");
    plt.plot(wind_sizes, [0.05 for i in wind_sizes], label = "Rejection level");

    ax.set_xlabel("Window size");
    ax.set_ylabel("Binomial test stat");

    ax.set_title(f"Binomial test value by window size for VaR {round(CONF_LEVEL*100, 2)}%")
    plt.xticks([i for i in range(250, 4000 + 1, 500)])

    plt.legend(["Test statistic","Rejection level"]);

    plt.savefig(fig_filepath)
    plt.show()


    plt.clf()


"""
Warning; this took 4 minutes to run on my computer, the plots for the 95, 99 and 99.9% confidence
levels are available in the Data/Plots/Backtesting folder already
"""
#window_analysis()