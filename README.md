# CoxRegression_AIDS
**Just a heads-up, I'm new to survival analysis myself, so if I mess up the logic or reasoning, cut me some slack, alright? :) Please feel free to reach out should you wish to correct me, I am more than happy to learn from my mistakes! :) **


Why is it important to test for proportionality of hazards before performing cox regression? Let us first understand what proportionality of hazards (PH) imply - that the relative risk or hazard ratios between two or more curves across different covariate levels remain constant over time. Checking PH assumptions can help detect if time-dependent variables are creating time-dependent effects on the hazard, thus making the hazard ratios non-constant over time. Cox regression relies on PH assumption because once this assumption is violated as a result of time-dependent variables, effect estimates that we derive from such cox regressions can be misleading.

Time-dependent effects that change the hazard ratios over time distort the interpretation of the results and impact the validity of the conclusions drawn from the analysis. In Cox PH model, HR is averaged over all event times.Therefore, if hazard ratios are non-constant and  increase over time, estimates can be overestimated at the beginning and underestimated at the end. 

In a study conducted in 1995, Altman and colleagues reviewed approximately 130 papers across five clinical oncology journals. They found that out of the 43 papers that utilised a Cox model, only 2 mentioned confirming the PH  assumption. Similarly, about a decade later, Mathoulin and colleagues evaluated the reporting quality of survival events in randomised clinical trials published in eight medical journals related to general or cancer medicine. They observed that among the 64 papers that used a Cox model, only one mentioned verifying the PH assumption. Not verifying PH assumptions when performing cox regression is a pressing matter in science. I shall attempt to demonstrate its implications by performing cox regression analysis on a simulated AIDS data with the following features:

- `id`: Patient identifier
- `time`: Time to event or censoring (in months)
- `treat`: Treatment group (0 = control, 1 = experimental treatment)
- `cd4`: CD4 cell count at baseline (a marker of immune system health)
- `aids`: Whether the patient progressed to AIDS (0 = no, 1 = yes)

To make it clear, the goal of this project is to understand the repercussions of the following in survival analysis:

Previous literature in survival analysis within healthcare has highlighted a lack of rigorous assessment of the Proportional Hazards (PH) assumption in Cox regression models. My research aims to delve into the consequences of treating a time-varying covariate as fixed in Cox regression. This investigation is crucial as it directly influences our predictions and can lead to time immortality bias, a phenomenon with significant implications in survival analysis.

Time-varying covariates may or may not necessarily have a time varying effect on hazard. We shall first test if our time-varying covariate induces a time-varying effect on hazard. Visual inspection does not suffice proving the violation of PH assumption. Therefore, we shall also conduct statistical tests to highlight how a time varying effect violates the assumption of proportional hazards. 

Firstly, I want to determine if there's any meaningful censoring in my dataset. My results in STATA indicate that there's no censoring due to patients dropping out; censoring only occurs when a patient hasn't experienced the event until the 10th month. If censoring in our dataset happens because patients haven't experienced the event of interest by the study's end (not due to dropout or other reasons), and this censoring isn't influenced by any variables in your model, it's termed "non-informative" or "non-differential" censoring. Non-informative censoring means the likelihood of being censored isn't related to the variables we are examining. In simpler terms, whether a patient would have experienced the event or not doesn't affect their being censored; they're censored because the study concluded, independent of the patients' characteristics or responses. Non-informative censoring is preferred in survival analysis as it ensures that the censoring process doesn't skew your findings. It lets you treat censored data as missing at random (MAR), a crucial assumption in survival analysis.


Now, I have coded a time-independent version of treat so that I can compare the Kaplan Meier graphs of both versions of treat. I would hypothesise that the time-independent version (‘treat_any_1’ as coded in STATA) will overestimate the effect of treatment compared to control on time to AIDS diagnosis:



As can be seen, the difference in curves is wider when ‘treat’ is considered time-independent compared to time-dependent. Therefore, one would have inferred an overestimation and considered treatment to decelerate the time to AIDS diagnosis. However, in reality, that is not the case as can be seen in the second graph.

It is important to note that solely relying on visual representation is insufficient to draw this conclusion. When performing univariate cox regression tests, we observe that on average, compared to control, treatment reduces AIDS risk by ~59% when treatment is time dependent. For time independent treatment effect, treatment reduces AIDS by a whopping 77% (ie an overestimation). Note: Here, we assume PH assumption holds. 


We shall also like to see if variable cd4 interacts with treat. In the context of AIDS which is caused by HIV, CD4 cells are particularly important. HIV targets and infects these cells, using them to replicate and spread throughout the body. As the virus multiplies, it gradually reduces the number of CD4 cells in the body. This depletion of CD4 cells undermines the immune system's ability to fight off infections and diseases, leading to the development of AIDS. Therefroe CD4 cell count is a key indicator of immune function in individuals infected with HIV. 





Relationship between cd4 and treat seems to differ across time. Therefore, we shall add an interaction term in the cox regression. Now that we have proven the overestimation effect of considering treatment effect as constant across time within individuals, we shall now only focus on analysis including time-dependent treatment effects. 

We notice a significant interaction between treatment and CD4 count indicating that the impact of CD4 count on the risk of AIDS cannot be generalised across treatment statuses, i.e., the effect of CD4 count is effectively moderated by whether or not an individual is receiving treatment and that. Specifically, for each unit increase in CD4 count, the hazard of developing AIDS for those receiving treatment reduced by 20% compared to those not receiving treatment, adjusting for the CD4 count itself. However, we have assumed here that PH assumptions are not violated. Therefore, we will now introduce a constructed time-dependent variable, i.e, an interaction term that involves time to the Cox model, and test for its significance. 

We've observed a significant interaction over time involving the factors CD4, treatment and interaction. This finding suggests that our PH  assumptions are not met, challenging the validity of our earlier analytical findings.

Residuals can be used to assess the PH assumption for continuous and categorical explanatory variables. We therefore perform Schoenfeld residual tests and notice a statistical significance, indicating that our cox model violates PH assumptions. Visual inspection too indicates that the lines are not constant over time:










