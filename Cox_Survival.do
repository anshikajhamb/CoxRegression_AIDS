stset time, failure(aids==1)


// Create a new variable "last_row" to indicate the last row for each "id"
sort id time


by id: gen last_row = _n == _N

// List or summarize the "aid" values for the last rows of each "id"
list id time aid if last_row

//this tells me that there is no censoring where the patient dropped out. censoring only happens when patient doesnt expeirence event until 10th month. 
//If censoring in your data occurs solely because patients did not experience the event of interest by the end of the study period (rather than due to dropout or other reasons), and this censoring mechanism is not dependent on any covariates or variables in your model, it's often referred to as "non-informative" or "non-differential" censoring.Non-informative censoring means that the probability of being censored is unrelated to the variables you are studying. In other words, it doesn't matter whether a patient would have experienced the event or not; they are censored simply because the study ended, and this is unrelated to any characteristics of the patients or their responses.Non-informative censoring is desirable in survival analysis because it ensures that the censoring process does not bias your results. It allows you to treat censored data as missing at random (MAR), which is a key assumption in survival analysis.
list id time aid if last_row & time != 10 & aid == 0


//create a non time dependent treat column to check how not taking into account time dependence affects our predictions/estimates
egen treat_any_1 = max(treat) , by(id)

// difference in kaplan meier. we would have overestimated treatment's effect on time to aids event, i.e., we would have inferred that patient developed aids later than sooner bc of treatment. However, visual depiction alone cannot help us conclude the previous statement. we need to run further statistical test to confirm non signficance 
sts graph, by(treat_any_1) ci
sts graph, by(treat) ci



//first perform univariate analyses 
stcox treat //hr<1, i.e, on avg, hazard rate for treat 1 decelerating compared to hazard rate of 0. 
stcox treat_any_1
stcox cd4 //a unit increase in cd4 scores increases hazard rate by 2%

 
preserve
collapse cd4, by(treat time)
twoway (line cd4 time if treat==0) /*
*/  (line cd4 time if treat==1), /*
*/  legend(order(1 "control when treat within patient time dependent" 2 "intervention  when treat within patient time dependent"))
restore


preserve
collapse cd4, by(treat_any_1 time)
twoway (line cd4 time if treat_any_1==0) /*
*/  (line cd4 time if treat_any_1==1), /*
*/  legend(order(1 "control when treat within patient non time dependent" 2 "intervention  when treat within patient non time dependent"))



//As a general rule, if the interaction is in the model, you need to keep the main effects in as well. Otherwise you're setting that main effect to = 0. Even if it's not far from 0, it generally isn't exactly 0. therefore we shall keep treat when testing for interaction between treat and cd4. want to see if change in treatment impacts cd4's effect on time to aids diagnosis. 
gen inter = treat*cd4 
stcox treat cd4 inter //sig ie  difference in effects between treat=0 and treat=1 on time to aids event depends on what the cd4 score is.


//now that we realise the importance of including time dependent covarites (time immortality bias), lets check if these time dependent covariates have a significant time dependent effect on the hazard. from 
gen time_var_cd= time*cd4
gen time_var_treat=time*treat
gen time_var_inter = time*inter


// check if time and concerned factor interactions are significant or not. If significant ie p-value<0.05, we can  conclude that with time, that concerned factor's effect on time to diagnosis changes. therefore, ph assumptions are indeed violated. 

//significant interactions
stcox cd4 treat inter time_var_inter time_var_cd time_var_treat
estat phtest, detail
estat phtest, plot(time_var_treat)
estat phtest, plot(time_var_cd)
estat phtest, plot(inter)
estat phtest, plot(treat)
estat phtest, plot(cd4)


	
//potential misspecification of time functions can induce bias. therefore, we also experiment with log and polynomial functions of time since theres a possibility that time's relationship with concerned factor is non-linear. (i did this separately and did not notice improvement compared to linear function, therefore, have omitted analysis here but have included the code in STATA)

gen timelog= log(time)
gen timepoly=time*time
gen cd_timelog = timelog*cd4
gen treat_timelog=timelog*treat
gen inter_timelog = inter*timelog 

stcox cd4 treat inter inter_timelog treat_timelog cd_timelog

restore
