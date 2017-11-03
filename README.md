# binoculaR

This is a convienece gadget that returns the Variable Names of a Labeled SPSS dataset. 

```r
# devtools::install_github("systats/binoculaR", force = T)
library(haven)
ess <- read_spss("https://github.com/systats/binoculaR/raw/master/data/ess_round8.sav")
binoculaR::binoculaR(ess)
```
