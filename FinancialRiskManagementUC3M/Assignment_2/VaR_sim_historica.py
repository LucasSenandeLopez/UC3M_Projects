import pandas as pd;
import numpy as np;

"""
    Estas constantes te permiten cambiar los parámetros del VaR con falicidad, la serie histórica
    entera que se puede usar es de 6001 miembros así que cualquier número mayor lanzará un error, de
    la misma manera que el resto de los parámetros deben ser verosímiles

    CONF_LEVEL es el nivel  de confianza determinado. Debe ser mayor a 0 y menor a 1.

    TOTAL_CARTERA representa el valor de la cartera.

    ALPHAS es el peso de cada activo en la cartera.

    

"""
CONF_LEVEL = 0.95;
PORTFOLIO_SIZE = 1_000_000;
HIST_SIM_DAYS = 6001;
ALPHAS = np.array([0.2, 0.1, 0.15, 0.35, 0.2]);

assert (PORTFOLIO_SIZE >= 0), "El valor de la cartera debe ser positivo"; 
assert (CONF_LEVEL > 0 and CONF_LEVEL < 1), "El nivel de confianza debe estar entre (0, 1)";
assert (HIST_SIM_DAYS< 6002 and HIST_SIM_DAYS > 0), "La serie histórica dura 6001 días";


ch_data = pd.read_csv("C:\\Users\\goomb\\OneDrive\\Documentos\\GitHub\\UC3M_Projects\\FinancialRiskManagementUC3M\\Data\\Assignment_2\\CloseData.csv",
                        date_format = "mm/dd/yy", index_col= "Date");

# Calcula cambios con respecto al día anterior, reusamos las mismas columnas por simplicidad
ch_data["Close_intel"] = np.log(ch_data["Close_intel"].shift(1)/ch_data["Close_intel"]);
ch_data["Close_exxon"] = np.log(ch_data["Close_exxon"].shift(1)/ch_data["Close_exxon"]);
ch_data["Close_jpmorgan"] = np.log(ch_data["Close_jpmorgan"].shift(1)/ch_data["Close_jpmorgan"]);
ch_data["Close_microsoft"] = np.log(ch_data["Close_microsoft"].shift(1)/ch_data["Close_microsoft"]);
ch_data["Close_pfizer"] = np.log(ch_data["Close_pfizer"].shift(1)/ch_data["Close_pfizer"]);

ch_data.drop(["Close_us500"], axis = 1, inplace = True); # No necesitamos el S&P500 en este caso
ch_data.drop(["2000-03-30"], axis = 0, inplace = True); # Esta fila tiene valores faltantes


Var_data_scenarios = np.sum(ch_data.iloc[:, -HIST_SIM_DAYS:] * PORTFOLIO_SIZE * ALPHAS, axis = 1);
VaR = round(abs(np.quantile(Var_data_scenarios, 1 - CONF_LEVEL)), 2);

"""
    El VaR con los parámetros:
    DIAS_SIM_HISTORICA = 6001 (Toda la serie)
    ALPHAS = [0.2, 0.1, 0.15, 0.35, 0.2]
    TOTAL_CARTERA = 1_000_000
    NIVEL_CONF = 0.95

    Es igual a 21394.26$
"""
print(f"El VaR por simulación histórica al 95% de confianza es: {VaR}$");

