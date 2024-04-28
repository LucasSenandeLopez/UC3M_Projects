import numpy as np;
import pandas as pd;
import matplotlib.pyplot as plt;

portfolio_filepath  = "C:\\Users\\goomb\\OneDrive\\Documentos\\GitHub\\";
portfolio_filepath += "UC3M_Projects\\FinancialRiskManagementUC3M\\Data\\Assignment_3\\PortfolioChange.csv";

portfolio_change = pd.read_csv(portfolio_filepath, date_format = "dd/mm/yyyy");


BACKTESTING_WINDOW = 1_000;
CONF_LEVEL = 0.95;
SERIES_LENGTH = len(portfolio_change.Change);

def hist_sim_var(change_arr : np.ndarray):

    global BACKTESTING_WINDOW;
    global CONF_LEVEL;

    bruh = 0;

    length = len(change_arr);

    result_arr = np.array([np.quantile(change_arr[(i - BACKTESTING_WINDOW):i], 1 - CONF_LEVEL) \
                           for i in range(BACKTESTING_WINDOW, length, 1)], dtype="float32");

    return result_arr;

change_arr = np.array(portfolio_change.Change);
var = hist_sim_var(change_arr)

n_exceptions = np.sum(change_arr[BACKTESTING_WINDOW:] < var)
exception_prop = n_exceptions / (len(portfolio_change.Change) -   BACKTESTING_WINDOW)

fig, ax = plt.subplots(figsize = (12,6))
ax.plot(portfolio_change.Date[BACKTESTING_WINDOW:], var, label = "VaR 95%")
ax.plot(portfolio_change.Date[BACKTESTING_WINDOW:], portfolio_change.Change[BACKTESTING_WINDOW:], \
         label = "Actual change", alpha = 0.3)

ax.set_title(f"We had {n_exceptions} exceptions with a proportion of {round(exception_prop, 4)}")
plt.xticks([portfolio_change.Date[i] for i in range(BACKTESTING_WINDOW, SERIES_LENGTH, 500)])
plt.show()


   
