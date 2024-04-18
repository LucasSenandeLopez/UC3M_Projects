# -*- coding: utf-8 -*-
"""
Created on Mon Apr  8 08:53:28 2024

@author: Alex Mayo

En este archivo, se calcula el VaR a un día y confianza del 95% por el método paramétrico estándar
y el VaRbeta tomando datos del período 2000-2024

"""
import pandas as pd
from scipy import stats
import numpy as np

closed_data=pd.read_csv("C:\\Users\\goomb\\OneDrive\\Documentos\\GitHub\\UC3M_Projects\\FinancialRiskManagementUC3M\\Data\\Assignment_2\\CloseData.csv")
vol_data=closed_data.copy()

"""
    Nota: nos referimos a los datos de cambio con respecto al día anterior como 'vol_'- pese a 
    que se refieren al cambio diario y cierre para simplificar; la volatilidad se obtendrá luego
    a través de transformaciones
""" 
vol_data["vol_intel"]=np.log(vol_data["Close_intel"].shift(1)/vol_data["Close_intel"]).dropna()
vol_data["vol_exxon"]=np.log(vol_data["Close_exxon"].shift(1)/vol_data["Close_exxon"]).dropna()
vol_data["vol_jpmorgan"]=np.log(vol_data["Close_jpmorgan"].shift(1)/vol_data["Close_jpmorgan"]).dropna()
vol_data["vol_microsoft"]=np.log(vol_data["Close_microsoft"].shift(1)/vol_data["Close_microsoft"]).dropna()
vol_data["vol_pfizer"]=np.log(vol_data["Close_pfizer"].shift(1)/vol_data["Close_pfizer"]).dropna()
vol_data["vol_us500"]=np.log(vol_data["Close_us500"].shift(1)/vol_data["Close_us500"]).dropna()

vol_data=vol_data.dropna()
vol_data=vol_data[['vol_intel', 'vol_exxon',
'vol_jpmorgan', 'vol_microsoft', 'vol_pfizer', 'vol_us500']]


saldo_cuenta=1_000_000

# Pesos de cada activo en la cartera
alphas=[0.2,0.1,0.15,0.35,0.2]
alpha_intel,alpha_exxon,alpha_jpmorgan,alpha_microsoft,alpha_pfizer=alphas
saldo_intel=alpha_intel*saldo_cuenta
saldo_exxon=alpha_exxon*saldo_cuenta
saldo_jpmorgan=alpha_jpmorgan*saldo_cuenta
saldo_microsoft=alpha_microsoft*saldo_cuenta
saldo_pfizer=alpha_pfizer*saldo_cuenta

# Precios al cierre del último día considerado
coste_ult_dia_intel=closed_data.tail(1)["Close_intel"]
coste_ult_dia_exxon=closed_data.tail(1)["Close_exxon"]
coste_ult_dia_jpmorgan=closed_data.tail(1)["Close_jpmorgan"]
coste_ult_dia_microsoft=closed_data.tail(1)["Close_microsoft"]
coste_ult_dia_pfizer=closed_data.tail(1)["Close_pfizer"]

confianza=0.05 # 1 - confianza
Z_conf= abs(stats.norm.ppf(confianza))



mean = lambda x: np.sum(x) / len(x)
standard_dev = lambda x: np.sqrt((np.sum(x**2) - len(x) * mean(x)**2) / (len(x) - 1))

# Volatilidades calculadas a lo largo de todo el período
sd_intel=standard_dev(vol_data["vol_intel"])
sd_exxon=standard_dev(vol_data["vol_exxon"])
sd_jpmorgan=standard_dev(vol_data["vol_jpmorgan"])
sd_microsoft=standard_dev(vol_data["vol_microsoft"])
sd_pfizer=standard_dev(vol_data["vol_pfizer"])

sd_us500=standard_dev(vol_data["vol_us500"])

# Betas
Beta_us500=1
Beta_intel=np.polyfit(np.array(vol_data["vol_us500"]), np.array(vol_data["vol_intel"]), 1)[0] 
Beta_exxon=np.polyfit(np.array(vol_data["vol_us500"]), np.array(vol_data["vol_exxon"]), 1)[0] 
Beta_jpmorgan=np.polyfit(np.array(vol_data["vol_us500"]), np.array(vol_data["vol_jpmorgan"]), 1)[0] 
Beta_microsoft=np.polyfit(np.array(vol_data["vol_us500"]), np.array(vol_data["vol_microsoft"]), 1)[0] 
Beta_pfizer=np.polyfit(np.array(vol_data["vol_us500"]), np.array(vol_data["vol_pfizer"]), 1)[0] 

# Para simplificar cálculos luego, multiplicamos aquí ya por la volatilidad del S&P500
beta_us500=Beta_us500*sd_us500
beta_intel=Beta_intel*sd_us500
beta_exxon=Beta_exxon*sd_us500 
beta_jpmorgan=Beta_jpmorgan*sd_us500 
beta_microsoft=Beta_microsoft*sd_us500 
beta_pfizer=Beta_pfizer*sd_us500

# Elementos del vector P
P_intel=sd_intel*saldo_intel
P_exxon=sd_exxon*saldo_exxon
P_jpmorgan=sd_jpmorgan*saldo_jpmorgan
P_microsoft=sd_microsoft*saldo_microsoft
P_pfizer=sd_pfizer*saldo_pfizer

P=[P_intel,P_exxon,P_jpmorgan,P_microsoft,P_pfizer]


vol_data_no_us=vol_data.drop("vol_us500",axis=1)
df_corr=vol_data_no_us.corr()



df_cov=vol_data_no_us.cov()

Varianza_cartera=np.matmul(np.matmul(alphas,df_cov),alphas)
Vol_cartera=np.sqrt(Varianza_cartera)
 



Var_indivs=list(np.array(P)*Z_conf)

Var_indiv_intel,Var_indiv_exxon,Var_indiv_jpmorgan,Var_indiv_microsoft,Var_indiv_pfizer=Var_indivs
print("El Var de intel: ",Var_indiv_intel)
print("El Var de exxon: ",Var_indiv_exxon)
print("El Var de jpmorgan: ",Var_indiv_jpmorgan)
print("El Var de microsoft: ",Var_indiv_microsoft)
print("El Var de pfizer: ",Var_indiv_pfizer)
print("")
print("")

Var_no_divers=sum(Var_indivs)
print("Var no diversificado: ", Var_no_divers)


Var_divers_por_matriz=np.sqrt(np.matmul(np.matmul(P,df_corr),P))*Z_conf
print("Var diversificado mediante calculo matricial de P y correlaciones: ",Var_divers_por_matriz)


Var_divers_paramatrico=Z_conf*Vol_cartera*saldo_cuenta
print("Var diversificado parametrico mediante volatilidad de la cartera: ",Var_divers_paramatrico)

print("\nPodemos ver que el diversificado es menor lo cual tiene sentido porque este\n", 
"es equivalente a calcular el no diversificado cuando toda las correlaciones son 1.")

print("")

print("Pequeña diferencia entre diversificados por calculos internos y redondeos;\n", 
"mismo caso que en excel al usar paquetes de python.")

print("")
print("")

Var_beta_intel=Z_conf*saldo_intel*beta_intel
Var_beta_exxon=Z_conf*saldo_exxon*beta_exxon
Var_beta_jpmorgan=Z_conf*saldo_jpmorgan*beta_jpmorgan
Var_beta_microsoft=Z_conf*saldo_microsoft*beta_microsoft
Var_beta_pfizer=Z_conf*saldo_pfizer*beta_pfizer


print("El Var beta de intel: ",Var_beta_intel)  
print("El Var beta  de exxon: ",Var_beta_exxon)
print("El Var beta  de jpmorgan: ",Var_beta_jpmorgan)
print("El Var beta  de microsoft: ",Var_beta_microsoft)
print("El Var beta  de pfizer: ",Var_beta_pfizer)









