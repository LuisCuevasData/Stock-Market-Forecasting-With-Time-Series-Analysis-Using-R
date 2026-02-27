# Stock-Market-Forecasting-With-Time-Series-Analysis-Using-R
Stock market forecasting in R using ARIMA (MSFT via Yahoo Finance) with stationarity tests, ACF/PACF analysis, and forecast evaluation.

# Stock Market Forecasting (ARIMA) 

This project uses **R** to download historical **Microsoft (MSFT)** stock data from **Yahoo Finance** and build a **time-series forecasting** model using **ARIMA**. The workflow includes data transformation, stationarity testing (ADF), ACF/PACF analysis, ARIMA modeling, forecasting, and basic validation.

## What I Did
- Pulled MSFT daily price history for **2020-01-01 to 2020-12-31** using `quantmod::getSymbols()`.
- Explored the time series visually (price chart + decomposition).
- Applied transformations to stabilize variance (**log** and **square root**).
- Applied **differencing** to make the series stationary for ARIMA modeling.
- Ran **Augmented Dickey-Fuller (ADF)** tests to verify stationarity.
- Used **ACF/PACF** plots to guide ARIMA parameter selection.
- Fit and forecasted using **ARIMA(2,0,2)** (rolling 1-step-ahead forecasts).
- Compared **Actual vs Forecasted** returns and evaluated prediction direction accuracy.

## Key Findings
### Stationarity (ADF Tests)
- The transformed close-price series **were not stationary**:
  - Log close price: p-value ≈ **0.4886** (not stationary)
  - Sqrt close price: p-value ≈ **0.4792** (not stationary)
- After differencing, both series became **stationary**:
  - Differenced log series: p-value **≤ 0.01**
  - Differenced sqrt series: p-value **≤ 0.01**

**Conclusion:** Differencing was necessary before fitting ARIMA to satisfy stationarity assumptions.

### Forecast Performance (Directional Accuracy)
- I evaluated forecasts using a **directional accuracy metric**:
  - Accuracy = whether the forecasted return had the **same sign** (up/down) as the actual return.
- Result: **44.44% directional accuracy** on the final evaluation window (9 forecast points in late Dec 2020).

**Conclusion:** The model captured some movement but did not consistently predict return direction in this short testing window.
