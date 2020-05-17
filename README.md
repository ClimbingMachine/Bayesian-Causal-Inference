# Quantifying-COVID19-on-Tourist-Visits

The objective of this project is to quantify the impact of COVID-19 pandemic on tourist visits (pedestrians + bikes) in regional parks in cities in North America (San Francisco, Seattle, New York, Indianapolis, Charlotte, and Long Beach). 

The datasets consists of observational tourist visits from 2020-01-01 to 2020-05-14. After 2020-03-10, these cities announced a work-from-home policy. We hope to quantify the effects of the COVID-19 on personal visists to parks. The real observations can be considered as the "Treatment". We developed a Bayesian Time Series Model to construct the "conterfactual" as the "Control" group. The pointwise differences between control and treatment are the "effects" that we hope to estimate. 

These codes are written in Stan through interfaces into R computing environments (RStan). The .R file is the original file. The Bayesian Time Series Model is construncted in /*Stan file for Tourist Visits Data*/.

Finally, datasets for this research can be found online. We are currently asking for research-use permission fromt the client. After the permission, we can upload several estimation results related to it.
