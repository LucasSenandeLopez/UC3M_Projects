import pandas as pd;
import numpy as np;

"""
    Estas constantes nos permiten cambiar los parámetros del VaR de forma sencilla
    siempre y cuando estos sean verosímiles:

    Z_CONF representa el Z_alpha para el nivel de confianza determinado.

    TOTAL_CARTERA es el valor de la cartera.

    DIAS_BETA son los días con los que se calculará la beta, debe ser un entero en 
    el intervalo [1, 6001].

    ALPHAS son los pesos de cada activo en la cartera.
"""
Z_CONF = 1.644854;
TOTAL_CARTERA = 1_000_000;
DIAS_BETA = 365;
ALPHAS = np.reshape(np.array([0.2, 0.1, 0.15, 0.35, 0.2]), (5, 1));

assert (TOTAL_CARTERA >= 0), "El valor de la cartera debe ser positivo";
assert (DIAS_BETA > 0 and DIAS_BETA < 6002), "El número de días para la beta debe estar entre [1, 6001]";

def value_at_risk(quantity, volatility, time, Z):
    """
    Calcula el VaR simple a través del producto de la volatilidad diaria, el valor monetario
    de la cartera, el tiempo y el nivel de confianza.
    """
    
    return (quantity * volatility * np.sqrt(time) * Z);


def diversified_var(col_vector_P : np.ndarray, corrmat : np.ndarray):
    """
    Calcula el VaR diversificado de varios activos usando operaciones matriciales
    de los vectores de VaR y la matriz de correlaciones.
    """
    
    return np.sqrt(col_vector_P.T @ corrmat @ col_vector_P)[0, 0];


def varBeta(beta_vector : np.ndarray, alpha_vec : np.ndarray, quantity, market_vol, time, Z):
    """
    Calcula el VaRBeta de una cartera de activos a través la volatilidad de la cartera, siendo
    esta calculada a través de la obtención de la matriz decovarianzas. Cabe destacar que el único
    factor de riesgo a considerar en este caso es el riesgo sistemático (de mercado).
    """

    cov_mat = (beta_vector @ beta_vector.T) * (market_vol ** 2);
    vol = np.sqrt(alpha_vec.T @ cov_mat @ alpha_vec);

    return (vol * quantity * np.sqrt(time) * Z)[0, 0];



vol_data = pd.read_csv("C:\\Users\\goomb\\OneDrive\\Documentos\\GitHub\\UC3M_Projects\\FinancialRiskManagementUC3M\\Data\\Assignment_2\\VolData.csv",
                   date_format ="mm/dd/yy", index_col= "Date");

ch_data = pd.read_csv("C:\\Users\\goomb\\OneDrive\\Documentos\\GitHub\\UC3M_Projects\\FinancialRiskManagementUC3M\\Data\\Assignment_2\\CloseData.csv",
                        date_format ="mm/dd/yy", index_col= "Date");

# Calculamos los cambios con respecto al día anterior, reusamos las columnas por simplicidad
ch_data["Close_intel"] = np.log(ch_data["Close_intel"].shift(1)/ch_data["Close_intel"]);
ch_data["Close_exxon"] = np.log(ch_data["Close_exxon"].shift(1)/ch_data["Close_exxon"]);
ch_data["Close_jpmorgan"] = np.log(ch_data["Close_jpmorgan"].shift(1)/ch_data["Close_jpmorgan"]);
ch_data["Close_microsoft"] = np.log(ch_data["Close_microsoft"].shift(1)/ch_data["Close_microsoft"]);
ch_data["Close_pfizer"] = np.log(ch_data["Close_pfizer"].shift(1)/ch_data["Close_pfizer"]);
ch_data["Close_us500"] = np.log(ch_data["Close_us500"].shift(1)/ch_data["Close_us500"]);

ch_data.drop(["2000-03-30"], axis = 0, inplace = True); # Esta fila tiene valores faltantes

# No cogemos la columna 0 para excluír al S&P500 en las correlaciones
corr_mat = np.array(ch_data.iloc[:, 1:].corr(), dtype = "float32");

"""
    Al coger las volatilidades calculadas con una ventana de 60 días,
    no vamos a tener en cuenta la del S&P500 ya que este vector lo usaremos 
    para calcular fácilmente el vector P, que ya contiene los VaRes individuales
"""
last_day_vols = np.reshape(np.array(vol_data.iloc[-1, 1:]), (5, 1)); 
vector_P = value_at_risk(TOTAL_CARTERA * ALPHAS, last_day_vols, 1, Z_CONF);

var_no_diversificado = np.sum(vector_P);
var_diversificado = diversified_var(vector_P, corr_mat);


betas = np.zeros((5, 1));
market_change_data = np.array(ch_data.iloc[-DIAS_BETA:, 0]);
market_var = np.var(market_change_data)

for i in range(1,6,1):

    stock_data = np.array(ch_data.iloc[-DIAS_BETA:, i]);

    both = np.vstack((stock_data, market_change_data));
    betas[i - 1, 0] = np.cov(both)[0, 1] / market_var;

var_beta = varBeta(betas, ALPHAS, TOTAL_CARTERA, vol_data.iloc[-1, 0], 1, Z_CONF);    

"""
    Usando los parámetros: 
        Z_CONF = 1.644854 (Correspondiente a nivel de confianza del 95%)
        TOTAL_CARTERA = 1_000_000
        DIAS_BETA = 365;
        ALPHAS = [0.2, 0.1, 0.15, 0.35, 0.2] (En matriz 5x1)

    Obtenemos:
        VaRes individuales: [8682.96 1875.83 2149.73 6628.7 6207.52] 
        VaR no diversificado: 25544.74$
        VaR diversificado: 19081.03$
        VaR beta: 12281.65$
"""

print(f"VaRes individuales: {np.round(vector_P[:, 0], 2)}",  
      f"\nVaR no diversificado: {round(var_no_diversificado, 2)}$", 
      f"\nVaR diversificado: {round(var_diversificado, 2)}$", 
      f"\nVaR beta: {round(var_beta, 2)}$");
