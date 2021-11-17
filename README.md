# Time-Series-Forecasting-of-Stocks-Data

Problem Statement:
Forecast the stock Price of a GE company based upon the publicly available data regarding the stock price on a monthly basis in the past.

Approach:
It is a case of univariate time series forecasting.
Preprocessed the data - checked for the nas and imputed them with recent non na values.
Tried various models like:
Simple Moving Average,Exponential Moving Average, Holtwinters Model, and Arima Models.

Simple Moving Average Summary:
Error metric on forecasted data Train
        mae         mse        rmse        mape 
15.5406503 534.6597162  23.1227100   0.0489867 
Error metric on forecasted Test Data
mae          mse         rmse         mape 
3.402507e+01 1.270559e+03 3.564490e+01 5.341695e-02 

Exponential moving Average:
Error Metrics on Train
        mae         mse        rmse        mape 
10.3604335 237.6265405  15.4151400   0.0326578 
Error Metrics on Test
         mae          mse         rmse         mape 
13.43073806 365.47688485  19.11744975   0.02082292

Holtwinters Model:
Error Metrics on Test Data:
Error metric on HW
         mae          mse         rmse         mape 
3.773307e+01 1.670860e+03 4.087616e+01 5.920131e-02 

Arima Models:
Error Metrics Arima model 1: 
mae          mse         rmse         mape 
2.671819e+02 7.152351e+04 2.674388e+02 4.215219e-01
Error Metrics Arima model 2:
Error metrics from model 3 
         mae          mse         rmse         mape 
5.328593e+01 4.302483e+03 6.559332e+01 8.518355e-02 
Error Metrics Arima model 3:
         mae          mse         rmse         mape 
14.65245587 241.30376809  15.53395533   0.02324786 

Error Metrics Auto Arima model :
mae          mse         rmse         mape 
12.10768897 147.99243278  12.16521405   0.01909538 


Best model out of all models generated is auto arima

