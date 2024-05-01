# -*- coding: utf-8 -*-
"""
Created on Wed May  1 21:58:34 2024

@author: PC-Alex
"""

import numpy as np;
import pandas as pd;
import matplotlib.pyplot as plt;
import scipy.stats as stats;

import warnings
warnings.simplefilter(action='ignore')

def get_Parametric_Beta_VAR(df_change_step, saldos, confidence_lvl):
    
    df_change_step=df_change_step[['vol_intel', 'vol_exxon',
    'vol_jpmorgan', 'vol_microsoft', 'vol_pfizer', 'vol_us500']]
    
    #Asumimos proporcion constante dia a dia
    saldo_intel=saldos[0]
    saldo_exxon=saldos[1]
    saldo_jpmorgan=saldos[2]
    saldo_microsoft=saldos[3]
    saldo_pfizer=saldos[4]
    
    alphas=saldos/sum(saldos)
    
    
    confianza=confidence_lvl # 1 - confianza
    Z_conf= abs(stats.norm.ppf(confianza))

    mean = lambda x: np.sum(x) / len(x)
    standard_dev = lambda x: np.sqrt((np.sum(x**2) - len(x) * mean(x)**2) / (len(x) - 1))

    # Volatilidades calculadas a lo largo de todo el período
    

    sd_us500=standard_dev(df_change_step["vol_us500"])

    # Betas
    Beta_intel=np.polyfit(np.array(df_change_step["vol_us500"]), np.array(df_change_step["vol_intel"]), 1)[0] 
    Beta_exxon=np.polyfit(np.array(df_change_step["vol_us500"]), np.array(df_change_step["vol_exxon"]), 1)[0] 
    Beta_jpmorgan=np.polyfit(np.array(df_change_step["vol_us500"]), np.array(df_change_step["vol_jpmorgan"]), 1)[0] 
    Beta_microsoft=np.polyfit(np.array(df_change_step["vol_us500"]), np.array(df_change_step["vol_microsoft"]), 1)[0] 
    Beta_pfizer=np.polyfit(np.array(df_change_step["vol_us500"]), np.array(df_change_step["vol_pfizer"]), 1)[0] 

    # Para simplificar cálculos luego, multiplicamos aquí ya por la volatilidad del S&P500
    beta_intel=Beta_intel*sd_us500
    beta_exxon=Beta_exxon*sd_us500 
    beta_jpmorgan=Beta_jpmorgan*sd_us500 
    beta_microsoft=Beta_microsoft*sd_us500 
    beta_pfizer=Beta_pfizer*sd_us500


    vol_data_no_us=df_change_step.drop("vol_us500",axis=1)

    df_cov=vol_data_no_us.cov()

    Varianza_cartera=np.matmul(np.matmul(alphas,df_cov),alphas)
    Vol_cartera=np.sqrt(Varianza_cartera)
       
    Var_divers_paramatrico=Z_conf*Vol_cartera*sum(saldos)

    Var_beta_intel=Z_conf*saldo_intel*beta_intel
    Var_beta_exxon=Z_conf*saldo_exxon*beta_exxon
    Var_beta_jpmorgan=Z_conf*saldo_jpmorgan*beta_jpmorgan
    Var_beta_microsoft=Z_conf*saldo_microsoft*beta_microsoft
    Var_beta_pfizer=Z_conf*saldo_pfizer*beta_pfizer


    return [Var_divers_paramatrico, Var_beta_exxon+Var_beta_intel+Var_beta_jpmorgan+Var_beta_microsoft+Var_beta_pfizer]



saldo_initial=1000000
portfolio_change_filepath  = "C:\\Users\\goomb\\OneDrive\\Documentos\\GitHub\\";
portfolio_change_filepath += "\\UC3M_Projects\\FinancialRiskManagementUC3M\\Data\\Assignment_3";

portfolio_value_filepath = portfolio_change_filepath + "\\PortfolioData.csv";


portfolio_value = pd.read_csv(portfolio_value_filepath, date_format = "dd/mm/yyyy");
portfolio_value=portfolio_value[["Date","portfolio_value"]]


path_close="C:\\Users\\goomb\\OneDrive\\Documentos\\GitHub\\UC3M_Projects\\FinancialRiskManagementUC3M\\Data\\Assignment_2\\CloseData.csv"
closed_data=pd.read_csv(path_close, date_format = "dd/mm/yyyy")



closed_data=closed_data.merge(portfolio_value,on="Date")




alpha=[0.2,0.1,0.15,0.35,0.2]

acc_intel=saldo_initial*alpha[0]/closed_data["Close_intel"].iloc[0]
acc_exxon=saldo_initial*alpha[1]/closed_data["Close_exxon"].iloc[0]
acc_jpmorgan=saldo_initial*alpha[2]/closed_data["Close_jpmorgan"].iloc[0]
acc_microsoft=saldo_initial*alpha[3]/closed_data["Close_microsoft"].iloc[0]
acc_pfizer=saldo_initial*alpha[4]/closed_data["Close_pfizer"].iloc[0]




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


BACKTESTING_WINDOW = 5500

CONF_LEVEL=0.95

specific_df=vol_data.copy()
last_date=[specific_df["Date"][-1:]]
last_value=specific_df["portfolio_value"][-1:]
specific_df.drop(specific_df.index[-1:], inplace=True)

result_list=[]
compare_df=portfolio_value.tail(BACKTESTING_WINDOW+1)

compare_df["next"]=compare_df["portfolio_value"].shift(-1)
compare_df.drop(compare_df.index[-1:], inplace=True)


for i in range(BACKTESTING_WINDOW):
    
    saldo_intel=acc_intel*specific_df["Close_intel"].iloc[-1]
    saldo_exxon=acc_exxon*specific_df["Close_exxon"].iloc[-1]
    saldo_jpmorgan=acc_jpmorgan*specific_df["Close_jpmorgan"].iloc[-1]
    saldo_microsoft=acc_microsoft*specific_df["Close_microsoft"].iloc[-1]
    saldo_pfizer=acc_pfizer*specific_df["Close_pfizer"].iloc[-1]
    saldos=[saldo_intel,saldo_exxon,saldo_jpmorgan,saldo_microsoft,saldo_pfizer]
    
    result_step=get_Parametric_Beta_VAR(specific_df,saldos,CONF_LEVEL)

    result_list.append([last_date[0].values[0]]+[-1*result_step[0]]+[-1*result_step[1]])

    specific_df.drop(specific_df.index[-1:], inplace=True)

    last_date=[specific_df["Date"][-1:]]
    last_value=specific_df["portfolio_value"][-1:]
    

result_df=pd.DataFrame(result_list,columns=["Date","Var_parametric","Var_beta"])

compare_df["change"]=compare_df["next"]-compare_df["portfolio_value"]
compare_df=compare_df[["Date","change"]]
result_df=result_df.merge(compare_df,on="Date")


result_df=result_df[::-1]


result_df["exception_parametric"]=(result_df['change'] < result_df['Var_parametric']).astype(int)
result_df["exception_beta"]=(result_df['change'] < result_df['Var_beta']).astype(int)

exceptions_beta=sum(result_df["exception_beta"])
exceptions_parametric=sum(result_df["exception_parametric"])

len_sample=len(result_df)

proportion_beta=exceptions_beta/len_sample
proportion_parametric=exceptions_parametric/len_sample



fig, ax = plt.subplots(figsize = (14,8))
plt.plot(result_df["Date"], result_df["Var_parametric"])
plt.plot(result_df["Date"], result_df["Var_beta"])
plt.plot(result_df["Date"], result_df["change"], \
         label = "Actual change", alpha = 0.3)

ax.set_title(f"{exceptions_beta} exceptions on beta and {exceptions_parametric} on parametric from a sample of {len_sample} with a proportion of {round(proportion_beta, 4)} and {round(proportion_parametric, 4)} respectively")

plt.xticks(result_df['Date'][::1000], rotation=45)
plt.tick_params(axis='x', labelrotation=45)
plt.legend([f"VaR {round(CONF_LEVEL*100,2)}% parametric",f"VaR {round(CONF_LEVEL*100,2)}% beta","Actual Change"])

plt.savefig("C:\\Users\\goomb\\OneDrive\\Documentos\\GitHub\\UC3M_Projects\\FinancialRiskManagementUC3M\\Data\\Plots\\Backtesting\\pVarBetaVar\\pVar_BetaVar.png")
plt.show()

plt.clf()







P = round(1 - CONF_LEVEL, 4);

print()
print()
print()

binom_test = 1 - stats.binom.cdf(exceptions_beta - 1, BACKTESTING_WINDOW, 1 - CONF_LEVEL);

model_message = f"When talking about beta VAR:";
model_message += f"The probability of having {exceptions_beta} or more out of {len_sample} samples ";
model_message += f"under a Binom({BACKTESTING_WINDOW}, {P}) is {round(binom_test, 4)}";

print(model_message); 

if binom_test < 0.05:
     
    print("Therefore, we reject the model under the binomial test"); 

else:
     
    print("Thus, we do not have evidence to reject the model under the binomial test");


print()
print()
print()








binom_test = 1 - stats.binom.cdf(exceptions_parametric - 1, BACKTESTING_WINDOW, 1 - CONF_LEVEL);

model_message = f"When talking about parametric VAR:";
model_message += f"The probability of having {exceptions_parametric} or more out of {BACKTESTING_WINDOW} samples ";
model_message += f"under a Binom({BACKTESTING_WINDOW}, {P}) is {round(binom_test, 4)}";

print(model_message); 

if binom_test < 0.05:
     
    print("Therefore, we reject the model under the binomial test"); 

else:
     
    print("Thus, we do not have evidence to reject the model under the binomial test");



print()
print()
print()





