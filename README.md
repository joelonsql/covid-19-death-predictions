# covid-19-death-predictions
Amatör COVID-19 modellering i R

## Sverige

Tabell nedan visar tidigare prognoser och aktuell prognos för nästa dag,
samt faktiskt utfall enligt Folkhälsomyndigheten.

Datum | Prognos | Facit | Fel
--- | --- | --- | ---
2020-03-29 | 124 (+22) | 110 (+8) | +14
2020-03-30 | 136 (+26) | 146 (+36) | -10
2020-03-31 | 167 (+21) | |

### 2020-03-29

[![](https://github.com/joelonsql/covid-19-death-predictions/blob/master/2020-03-29.png?raw=true)](https://rpubs.com/purrpurr/591606)

```
Model fitted: Log-logistic (ED50 as parameter) (3 parms)

Parameter estimates:

                Estimate Std. Error  t-value   p-value    
b:(Intercept)    -3.6546     0.2701 -13.5305 8.245e-10 ***
d:(Intercept)  5212.6949 11112.7302   0.4691    0.6458    
e:(Intercept)    52.4726    32.7210   1.6036    0.1296    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error:

 4.791973 (15 degrees of freedom)
```

### 2020-03-30

[![](https://github.com/joelonsql/covid-19-death-predictions/blob/master/2020-03-30.png?raw=true)](https://rpubs.com/purrpurr/591611)

```
Model fitted: Log-logistic (ED50 as parameter) (3 parms)

Parameter estimates:

                 Estimate  Std. Error t-value   p-value    
b:(Intercept)    -3.40029     0.34603 -9.8267 3.502e-08 ***
d:(Intercept)  2915.43607 10485.53738  0.2780    0.7845    
e:(Intercept)    48.47672    57.05671  0.8496    0.4081    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error:

 5.17592 (16 degrees of freedom)
```

### 2020-03-31

[![](https://github.com/joelonsql/covid-19-death-predictions/blob/master/2020-03-31.png?raw=true)](https://rpubs.com/purrpurr/591994)

```
Model fitted: Log-logistic (ED50 as parameter) (3 parms)

Parameter estimates:

                 Estimate  Std. Error  t-value   p-value    
b:(Intercept)    -3.49533     0.20634 -16.9397 4.431e-12 ***
d:(Intercept)  6506.98823 17609.93213   0.3695    0.7163    
e:(Intercept)    59.35287    49.09315   1.2090    0.2432    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error:

 5.212881 (17 degrees of freedom)
```
