## Purdue University Global
#
# IN400 - AI: Deep Learning and Machine Learning
# 
# Unit 8 Assignment / Module 5 Competency Assessment Part 2 
#
# Stock Market Forecasting
#
# R Studio Code
#
# Purpose
# In this assignment, we will practice the implementation of a financial 
# forecasting model to enforce the learning from the case studies. 
# In this assignment, we will use data acquired directly from 
# https://finance.yahoo.com for a stock symbol of our choice 
# (Assignment used Microsoft: MSFT) and use the ARIMA Univariate 
# Time Series using R, to forecast the behavior of the chosen stock. 
# The "Knit" function will render a report document and 
# display a preview of it. This is done by selecting 
# FILE-->KNIT DOCUMENT from the R Studio IDE menu. 
# Choose the "Microsoft Word" option for the report output.

# Package names
packages <- c("forecast","quantmod","tseries","timeSeries","xts") 

# Install packages not yet installed
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
} 

# Packages loading
invisible(lapply(packages, library, character.only = TRUE)) 
library("forecast")
library("quantmod")
library("tseries")
library("timeSeries")
library("xts")

# Declare Variables that allows choosing a stock 
# symbol and start/end dates of downloaded history
NameOfStock = 'MSFT'
StartDate = '2020-01-01'
EndDate = '2020-12-31'

# Pull data from Yahoo finance and display it
Stock_Data = getSymbols(c(NameOfStock), src="yahoo", from=StartDate, 
                        to=EndDate,auto.assign = FALSE)
summary(Stock_Data)

# Omit all NA records and Display the Data
Stock_Data = na.omit(Stock_Data)
summary(Stock_Data)

# Plot Chart time series
barChart(Stock_Data, theme="black", name=c(NameOfStock))

# Select the relevant close price series and display data
close_price = Stock_Data[,4]
summary(close_price)

# ARIMA Model
# Decomposition is the foundation for building the ARIMA 
# model by providing insight towards the changes in stock 
# fluctuations. For more analysis, decompose the data
# into seasonal, and trend components and plot result
Stock_Data.ts = ts(close_price, start=2020-01-02, frequency=120)
Stock_Data.de = decompose(Stock_Data.ts)

# Plot decomposed data
plot(Stock_Data.de)

# To smoothen the data and stabilize variance, calculate the 
# logarithmic returns and the square root values from the prices.
par(mfrow=c(1,1))

# Compute the log returns for the stock
close_price_log = log(close_price)
plot(close_price_log, type='l', xlab='Time', ylab='Log(close_price)', 
     main='Logarithmic Close Price Returns')

# Compute the sqrt returns for the stock
close_price_sqrt = sqrt(close_price)
plot(close_price_sqrt,type='l', xlab='Time', ylab='Sqrt(close_price)', 
     main='Square Root of Close Price Returns')

# A time series is stationary when its statistical properties such as 
# mean, variance, autocorrelation, etc. are all constant over time. 
# Stationarizing a time series through differencing (where needed)
# is an important part of the process of fitting an ARIMA model.

# Compute the difference of log returns for the stock and plot log returns
close_price_log_diff = diff(log(close_price),lag=1)
close_price_log_diff= close_price_log_diff[!is.na(close_price_log_diff)]

# Plot log returns
plot(close_price_log_diff,type='l', xlab='Time', ylab='Log(close_price)', 
     main='Difference of Log Close Price Returns')

# Compute the square root of returns for the stock and plot sqrt returns
close_price_sqrt_diff = diff(sqrt(close_price),lag=1)
close_price_sqrt_diff = close_price_sqrt_diff[!is.na(close_price_sqrt_diff)]

# Plot sqrt returns
plot(close_price_sqrt_diff,type='l', xlab='Time', ylab='Sqrt(close_price)', 
     main='Difference of Square Root Close Price Returns')

# Conduct Augmented Dickey Fuller (ADF) Test on log returns series 
# to confirm that the stationarity of data to fit an ARIMA model
print(adf.test(close_price_log))
print(adf.test(close_price_sqrt))
print(adf.test(close_price_log_diff))
print(adf.test(close_price_sqrt_diff))

# Apply the AutoCorrelation Function (ACF) and the Partial 
# AutoCorrelation Function (PACF) to prepare data for the ARIMA model
par(mfrow = c(1,2))
acf.stock = acf(close_price_log , main='ACF Plot', lag.max=100)
pacf.stock = pacf(close_price_log , main='PACF Plot', lag.max=100)

par(mfrow = c(1,2))
acf.stock = acf(close_price_sqrt, main='ACF Plot', lag.max=100)
pacf.stock = pacf(close_price_sqrt , main='PACF Plot', lag.max=100) 

# Programming A Fitted Forecast
# Initialize real log returns via xts
realreturn = xts(0, as.Date("2020-11-25", "%Y-%m-%d"))

# Initialize forecasted returns via dataframe
Forecastreturn = data.frame(Forcasted = numeric())

# Split the dataset in two parts - training and testing
split = floor(nrow(close_price_log_diff)*(2.9/3))

# To compute a working model, loop to forecast returns for each data 
# point, and return a time series for both real and forecast values:
for (s in split:(nrow(close_price_log_diff)-1)) {
  stock_train = close_price_log_diff[1:s, ]
  stock_test = close_price_log_diff[(s+1):nrow(close_price_log_diff), ]
  
  # Summary of the ARIMA model using the determined (p,d,q) parameters
  fit = arima(stock_train, order = c(2, 0, 2),include.mean=FALSE)
  summary(fit)
  
  # Forecasting the log returns
  arima.forecast = forecast(fit, h = 1,level=99)
  summary(arima.forecast)
  Box.test(fit$residuals, lag=1, type = 'Ljung-Box')
  
  # Creating a series of forecasted returns for the forecasted period
  Forecastreturn = rbind(Forecastreturn,arima.forecast$mean[1])
  colnames(Forecastreturn) = c("Forecasted")
  
  Actual_series = close_price_log_diff[(s+1),]
  realreturn = c(realreturn,xts(Actual_series))
  rm(Actual_series)
}

# plotting am ACF plot of the residuals
acf(fit$residuals,main="Residuals plot")

# plotting the forecast
par(mfrow=c(1,1))
plot(arima.forecast, main = "ARIMA Forecast")

# Visualizing the Model Results
# Adjust the length of the Actual return series
realreturn = realreturn[-1]

# Create a time series object of the forecasted series
Forecastreturn = xts(Forecastreturn,index(realreturn))

# Function to add Actual and Forecasted at the same time
PlotBoth<-function(){
  # Create a plot of the two return series - Actual versus Forecasted
  plot(realreturn, type='l', main='Actual(Black) vs Forecasted(Red)')
  # Add a line
  lines(Forecastreturn, lwd=2, col='red')
}
PlotBoth()

# Create a plot of the two return series - Actual versus Forecasted
plot(realreturn,type='l',main='Actual Returns Vs Forecasted Returns')
lines(Forecastreturn,lwd=1.5,col='red')
legend('bottomright',c("Actual","Forecasted"),lty=c(1,1),
       lwd=c(1.5,1.5),col=c('black','red'))

# Validating the Model Results
# Create a table for the accuracy of the forecast
realreturn
Forecastreturn
comparsion = merge(realreturn,Forecastreturn)
comparsion$Accuracy = sign(comparsion$realreturn)==sign(comparsion$Forecasted)
print(comparsion)

# Compute the accuracy percentage metric
Accuracy_percentage = sum(comparsion$Accuracy == 1)*100/length(comparsion$Accuracy)
print(Accuracy_percentage)
