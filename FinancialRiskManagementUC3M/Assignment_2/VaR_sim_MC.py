import numpy as np;
import pandas as pd;

"""
    Estas constantes nos permiten cambiar el escenario con el que calculamos el VaR;

    DIAS_CHOL nos permite determinar con cuántos días calculamos la matriz de Cholesky, debe ser
    un número entero positivo menor a 6002

    SAMPLES_MC determina cuántos escenarios generamos para cada distribución; debe ser un número
    entero positivo

    PORTFOLIO_SIZE representa el valor de la cartera.

    WEIGHTS es el valor de cada activo en la cartera.

    CONF_LEVEL es el nivel  de confianza determinado. Debe ser mayor a 0 y menor a 1.

    La semilla nos permite replicar resultados.
"""

DIAS_CHOL = 6001;
SAMPLES_MC = 5000;
PORTFOLIO_SIZE = 1_000_000;
WEIGHTS = PORTFOLIO_SIZE * np.array([0.2, 0.1, 0.15, 0.35, 0.2]);
CONF_LEVEL = 0.95;
np.random.seed(1)

assert (DIAS_CHOL < 6002 and DIAS_CHOL > 0 and (DIAS_CHOL == int(DIAS_CHOL))), \
    "El número de días debe ser un entero en el intervalo [1, 6001]";

assert (SAMPLES_MC > 0 and (SAMPLES_MC == int(SAMPLES_MC))), \
    "El tamaño de la muestra de cada simulación debe ser un entero mayor a 0";

assert (CONF_LEVEL > 0 and CONF_LEVEL < 1), "El nivel de confianza debe estar entre (0, 1)";


def monte_carlo_sim_normal(volatility : np.ndarray, chol_mat : np.ndarray):
    """
        Crea una simulación de monte carlo de tamaño especificado por la constante
        global 'SAMPLES_MC' usando una distribución normal estándar y un array
        de volatilidades con un método de tres pasos:

        Paso 1: Calcular Zv = Matriz_de_Cholesky x (Y1, Y2, ...)' 

        Paso 2: Calcular rendimientos simulados = e^(Zv * volatilidades)

        Paso 3: Obtener la muestra de pérdidas simuladas como la suma ponderada de los 
        rendimientos simulados
    """

    global SAMPLES_MC;
    global WEIGHTS;

    sample_normal = np.random.standard_normal(size = (SAMPLES_MC, 5)) @ chol_mat;
    sample_normal = np.exp(sample_normal * volatility);
    sample_normal = np.sum(sample_normal * WEIGHTS, axis = 1);

    return sample_normal;

def monte_carlo_sim_student_t(volatility : np.ndarray, chol_mat : np.ndarray, dof : int):
    """
        Crea una simulación de monte carlo de tamaño especificado por la constante
        global 'SAMPLES_MC' usando una distribución normal estándar y un array
        de volatilidades con un método de tres pasos:

        Paso 1: Calcular Zv = Matriz_de_Cholesky x (Y1, Y2, ...)' 

        Paso 2: Calcular rendimientos simulados = e^(Zv * volatilidades)
        
        Paso 3: Obtener la muestra de pérdidas simuladas como la suma ponderada de los 
        rendimientos simulados
    """

    global SAMPLES_MC;
    global WEIGHTS;

    sample_t = np.random.standard_t(df = dof, size = (SAMPLES_MC, 5)) @ chol_mat;
    sample_t = np.exp(sample_t * volatility);
    sample_t = np.sum(sample_t * WEIGHTS, axis = 1);

    return sample_t;

def multiple_dist_var(volatilities : np.ndarray, chol_mat : np.ndarray, ddofs : list):
    """
        Devuelve un np.ndarray con el VaR a un día con nivel de confianza dictado por la constante global
        'CONF_LEVEL' calculado como simulación de Monte Carlo de:

            - Distribución N(0, 1).
            - Distribuciones t de Stundent con grados de libertad indicados por el input 'ddofs'.

        Para un tamaño o valor de cartera y unas volatilidades determinadas por los inputs:
            'portfolio_size' y 'volatilities' respectivamente.
    
    """

    global CONF_LEVEL;
    global PORTFOLIO_SIZE;
    
    

    var_row = [monte_carlo_sim_normal(volatilities, chol_mat) - PORTFOLIO_SIZE];
    var_row += [monte_carlo_sim_student_t(volatilities, chol_mat, dof) - PORTFOLIO_SIZE 
                for dof in sorted(ddofs, reverse = True)];

    var_row = np.quantile(np.array(var_row).T, 1 - CONF_LEVEL, axis = 0);  

    return np.abs(np.round(var_row, 2)); #Devolvemos el valor absoluto de los VaRes redondeados.



vol_data = pd.read_csv("C:\\Users\\goomb\\OneDrive\\Documentos\\GitHub\\UC3M_Projects\\FinancialRiskManagementUC3M\\Data\\Assignment_2\\VolData.csv",
                   date_format ="mm/dd/yy", index_col= "Date");

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


corr_mat = ch_data.iloc[-DIAS_CHOL:, :].corr();
chol_mat = np.linalg.cholesky(corr_mat);


var_095 = multiple_dist_var(np.array(vol_data.iloc[-201, 1:]).flatten(), 
                                  chol_mat, [1, 2, 5, 10]);

"""
    Los VaRes calculados con la seed = 1:

    ~19708 usando la distribución normal con media 0 y desv. típica 1.
    ~22198 usando la distribución t de student con 10 grados de libertad.
    ~24901 usando la distribución t de student con 5 grados de libertad.
    ~40014 usando la distribución t de student con 2 grados de libertad.
    ~141243 usando la distribución t de student con 1 grado de libertad.

"""

print(f"Los VaRes obtenidos son: {var_095}");
   
print(chol_mat)






