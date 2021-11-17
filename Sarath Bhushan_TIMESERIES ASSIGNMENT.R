rm(list=ls(all=T))
setwd("C:\\Users\\Lokesh Bharat\\Desktop\\lab resources\\CSE7302\\18th Nov")
library(forecast)
library(lubridate)
library(DataCombine)
library(imputeTS)
library(plyr)
library(dplyr)
library(TTR)
library(graphics)
library(data.table)
library(Quandl)
library(DMwR)

GESTOCK<-read.csv("BSE-BOM532309.csv",sep = ",",header = T)
names(GESTOCK)
str(GESTOCK)
GESTOCK$Date<-as.Date(GESTOCK$Date,format="%Y-%m-%d")
stocktimedata<-GESTOCK[,c("Date","Close")]

minDate = min(as.Date(stocktimedata$Date,format="%Y-%m-%d"))
maxDate = max(as.Date(stocktimedata$Date,format="%Y-%m-%d"))

sequence <- data.frame("dateRange"=seq(minDate,maxDate,by="days"))

gestockmerge <- sequence %>% full_join(stocktimedata,c("dateRange" = "Date"))

sum(is.na(gestockmerge))

gestockmerge<-as.data.frame(gestockmerge)
# Imputing missing Values
gestockmerge$Close<-na.locf(gestockmerge$Close)
head(gestockmerge)
sum(is.na(gestockmerge))

gestockmerge$YEAR <-as.numeric(format(gestockmerge$dateRange,format="%Y"))
gestockmerge$MONTH<-as.numeric(format(gestockmerge$dateRange,format="%m"))

gestockmerge <- gestockmerge[order(gestockmerge$YEAR,gestockmerge$MONTH),]

gemonth <- gestockmerge %>% group_by(YEAR,MONTH) %>% summarise("Avg Closing Price by Month" = mean(Close))

gemonth<-as.data.frame(gemonth)
dim(gemonth)

Train <- gemonth[1:(nrow(gemonth) - 3),]
dim(Train)
Test <- gemonth[(nrow(gemonth) - 2):nrow(gemonth),]

Price <- ts(Train$`Avg Closing Price by Month`, frequency =12,start = c(2000,3))
Price
plot(Price,type="l",lwd=3,col="red",xlab="Month",ylab="Price",main="Time series plot for Stock of GE")

Pricedecomposed = decompose(Price)
plot(Pricedecomposed,col="Red")

par(mfrow=c(2,2))
acf(Price,lag=30)
pacf(Price,lag=30)

ndiffs(Price)


fitsma <- SMA(Price,n=2)
head(fitsma)
predsma <- forecast(fitsma[!is.na(fitsma)],h=3)
smaTrainMape <- regr.eval(Price[2:length(Price)],fitsma[2:length(Price)])
smaTestMape <- regr.eval(Test$`Avg Closing Price by Month`,predsma$mean)
smaTrainMape
smaTestMape
#Error metric on forecasted data Train
#        mae         mse        rmse        mape 
#15.5406503 534.6597162  23.1227100   0.0489867 
#Error metric on forecasted Test Data
#mae          mse         rmse         mape 
#3.402507e+01 1.270559e+03 3.564490e+01 5.341695e-02 
#####################################################################
fitwma<- WMA(Price,n=2,1:2)
predwma <- forecast(fitwma[!is.na(fitwma)],h=3)
plot(predwma)

wmaTrainMape <- regr.eval(Price[2:length(Price)],fitwma[2:length(Price)])
wmaTestMape <- regr.eval(Test$`Avg Closing Price by Month`,predwma$mean)
wmaTrainMape
wmaTestMape

### Exponential Moving Averages
fitEma <- EMA(Price, n = 2)
# Forecasting for book price the next 4 weeks
predema <- forecast(fitEma[!is.na(fitEma)],h=3)
plot(predema)

### Define the metric MAPE 
emaTrainMape <- regr.eval(Price[2:length(Price)],fitEma[2:length(Price)])
emaTestMape <- regr.eval(Test$`Avg Closing Price by Month`,predema$mean)
emaTrainMape
#        mae         mse        rmse        mape 
#10.3604335 237.6265405  15.4151400   0.0326578 
emaTestMape
#         mae          mse         rmse         mape 
#13.43073806 365.47688485  19.11744975   0.02082292 

# Build a HoltWinters model  with trend 
holtpriceforecast <- HoltWinters(Price,gamma=FALSE)
head(holtpriceforecast$fitted)

## HoltWinters model  with trend  and Seasonality
priceholtforecast <- HoltWinters(Price, beta=TRUE, gamma=TRUE, seasonal="additive")
head(priceholtforecast$fitted)

# Since you are building the models on weekly data, you will get 52 seasonal components. 
# If you are reading the monthly data, you will get 12 seasonal components

### Prediction on the Train
holtforecastTrain <- data.frame(priceholtforecast$fitted)
holtforecastTrainpredictions <- holtforecastTrain$xhat
head(holtforecastTrainpredictions)

### Prediction on test data
holtpriceforecast<-  forecast(priceholtforecast,h = 3)
plot(holtpriceforecast,ylim = c(-1000,1000))

### Define the metric hw 
hwTestMape <- regr.eval(Test$`Avg Closing Price by Month`,holtpriceforecast$mean)
hwTestMape
#Error metric on HW
#         mae          mse         rmse         mape 
#3.773307e+01 1.670860e+03 4.087616e+01 5.920131e-02 

### Arima Models
model1 <- arima(Price,c(0,0,0))
model1
acf(Price) 
pacf(Price)
plot(Price)

# Differencing once to stationarize, i.e d=1
model2 <- arima(Price,c(0,1,0))#aic = 2155.69
model2
acf(diff(Price,lag = 1))
pacf(diff(Price,lag = 1))
plot(diff(Price))

# plot has still non stationary behaviour another difference can stationarize it 
model3 <- arima(Price,c(0,2,0))#aic=2218
model3
plot(diff(Price,differences = 2))
acf(diff(Price,differences = 2))
pacf(diff(Price,differences = 2))

# Observing the acf and pacf there is significant lag in acf and also in pacf that has to be taken care 
model4 <- arima(Price,c(2,2,2))#aic=2136
model4

## Plots of the models
par(mfrow=c(2,2))
plot(model1$residuals,ylim=c(-100,100))
plot(model2$residuals,ylim=c(-100,100))
plot(model3$residuals,ylim=c(-100,100))
plot(model4$residuals,ylim=c(-100,100))

###  Auto Arima
MODEL_ARIMA <- auto.arima(Price, ic='aic')
summary(MODEL_ARIMA)
#AIC= 2138
### Box Ljung Test

set.seed(12334)
x <- rnorm (100)
Box.test (x, lag = 1)
Box.test (x, lag = 1, type = "Ljung")

# Box test on our auto.arima model
Box.test(MODEL_ARIMA$residuals, lag = 10, type = "Ljung-Box")

# This statistic can be used to examine residuals from a time series   are not correlated in order to see if all underlying population    autocorrelations for the errors may be 0.
# Null hypothesis: error is not correlated
# Alt hypothesis: error is correlated

### Forecast on the models 
pricearimaforecasts1 <- forecast(model1, h=3)
plot(pricearimaforecasts1)
pricearimaforecast3 <- forecast(model3, h=3)
plot(pricearimaforecast3)
pricearimaforecast4 <- forecast(model4, h=3)
plot(pricearimaforecast4)
pricearimaforecasts_autArima<- forecast(MODEL_ARIMA,h=3)
plot(pricearimaforecasts_autArima,flwd = 2)


# Model 1 was constructed with no trend and no seasonality and therefore the prediction will be same as present.
# Model3 has both trend and seasonality.

### Define the metric ARIMA 
arimaModel1TestMape <- regr.eval(Test$`Avg Closing Price by Month`,pricearimaforecasts1$mean)
arimaModel1TestMape
#eRROR mETRIC ON RESIDUALS ON TEST DATA 
#mae          mse         rmse         mape 
#2.671819e+02 7.152351e+04 2.674388e+02 4.215219e-01

arimaModel3TestMape <- regr.eval(Test$`Avg Closing Price by Month`,pricearimaforecast3$mean)
arimaModel3TestMape
#Error metrics from model 3 
#         mae          mse         rmse         mape 
#5.328593e+01 4.302483e+03 6.559332e+01 8.518355e-02 
arimaModel4TestMape <- regr.eval(Test$`Avg Closing Price by Month`,pricearimaforecast4$mean)
arimaModel4TestMape
#
#         mae          mse         rmse         mape 
#14.65245587 241.30376809  15.53395533   0.02324786 
### Define the metric AUTO ARIMA 

autoarimaTestMape <- regr.eval(Test$`Avg Closing Price by Month`,pricearimaforecasts_autArima$mean)
autoarimaTestMape
#Error Metric on Residuals on test data, of auto arima model
#mae          mse         rmse         mape 
#12.10768897 147.99243278  12.16521405   0.01909538 

# 1 Auto arima model with an MAPE of (0.019) has thrown up least Mape on residuals
# 2 Manual Arima 4 has thrown up MAPE Of (0.023)

# Best model out of all models generated is auto arima
