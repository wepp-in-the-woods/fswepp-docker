<?phphttps:https:https:https:https:
require("http://forest.moscowfsl.wsu.edu/smp/solo/shared/header1.php");
?>
    <title>Soil-Site Model Validation</title>
<?php
require("http://forest.moscowfsl.wsu.edu/smp/solo/shared/stylesheet.php");
//invoke_stylesheet();
require("http://forest.moscowfsl.wsu.edu/smp/solo/shared/header2.php");
?>
		<meta name="description" content="Soil-Site Model Validation" />
		<meta name="keywords" content="Soil-Site Model Validation" />
<?php
require("http://forest.moscowfsl.wsu.edu/smp/solo/shared/header3.php");
?>
<!-- BEGIN PUBLICATION -->
	<div id="pub">
		<div id="psubnav"><p><a href="../../../index.php">SOLO HOME</a> &gt; <a href="../../research_papers.php">RESEARCH PUBLICATIONS</a></p>
		</div>
	<h1>VALIDATION OF SOIL-SITE MODELS</h1> 
	<p class="authors">
		David L. Verbyla</p>
	<h2>ABSTRACT</h2> 
	<p>Hundreds of soil-site models have been published without being validated; such models may have prediction bias. The potential for prediction bias is especially high when many candidate predictor variables from a small sample are tested for during model development. Because of potential prediction bias, all soil-site models must be validated before being accepted. Two resampling procedures, cross-validation and the bootstrap, are introduced as simple statistical methods of validating soil-site models. These resampling methods provide a nearly unbiased estimate of the expected accuracy of a model. They are simple to computer program, and require no new data. The author recommends that soil scientists use a resampling procedure for the initial validation of soil-site models prior to expensive field validation.</p>
	<h2>INTRODUCTION</h2> 
	<p>Forest site quality in the Rocky Mountains is often expressed as site index: the average height of dominant and codominant trees at a base age of 50 or 100 years. Site index must be indirectly estimated where site trees are unavailable for direct measurement. A common indirect method is the soil-site model where site index is modeled as a function of soil, topographic, and vegetation factors. This approach has been accepted since the 1950's, and hundreds of soil-site equations have been published (Carmean 1975; Grey 1983).</p>
	<p>However, many of these soil-site models have been published without validating them. The objective of this paper is to demonstrate that soil-site models can have severe prediction bias and therefore must be validated as part of the modeling process. I will then introduce some simple statistical validation techniques that require no new data and provide a nearly unbiased estimate of model accuracy.</p>
	<h2>PREDICTION BIAS</h2> 
	<p>Suppose we measure site index and soil pH from two forest stands. We can then develop a regression model that predicts site index as a linear function of soil pH (<a href="#fig1">fig. 1</a>). The model has a high apparent accuracy; the site index of the two stands is perfectly predicted by our regression model. However, the model probably has prediction bias because the actual accuracy of the model is probably less than perfect prediction.</p>

	<p class="figure">
		<em class="bld"><a name="fig1"></a>Figure 1</em>&#8212;Linear regression based on two hypothetical sample cases. <a href="graphics/verbyla_fig1_lg.gif">[view larger image - 8K]</a>
		<br />
		<br />
		 <a href="graphics/verbyla_fig1_lg.gif"><img src="graphics/verbyla_fig1.gif" alt="Graph showing linear regression based on two hypothetical sample cases (explained within the text)." width="500" height="447" border="0" /></a>
	</p>

	<p>The potential for prediction bias is great if many predictor variables are used in the model and the sample size is small. This is because spurious correlations (due to chance) may be incorporated in the model if many potential predictor variables are tested during model development. For example, I developed a regression model that had an <em class="ital">R</em><sup>2</sup> of 0.99 and a linear discriminant model that correctly classified 95 percent of the sample cases; however, both these models were totally useless because they were developed with random numbers (Verbyla 1986). McQuilkin (1976) illustrated the same prediction bias problem by developing a soil-site regression with real data. His regression equation had an <em class="ital">R</em><sup>2</sup> of 0.66; but when it was validated with independent data, the correlation between the actual and predicted site indices was less than 0.01 (McQuilkin 1976).</p>
	<h2>MODEL VALIDATION BY RESAMPLING METHODS</h2> 
	<p>Because of potential prediction bias, soil-site models must be validated before being accepted. An intuitive approach is to randomly save half the sample cases for validation purposes. However, this is not a good idea. Consider <a href="#fig2">figure 2</a>: 20 sample cases are predicted by the linear discriminant boundary with an apparent accuracy of 90 percent. If we randomly select 10 sample cases to be excluded from model development (essentially sacrificed for model validation), two problems occur (<a href="#fig3">fig. 3</a>). First, we do not have a reliable estimate of the slope of the linear discriminant boundary (also our model degrees of freedom are reduced by half). Second, we only have one validation estimate of model accuracy, and this estimate is not very precise (<a href="#fig3">fig. 3</a>).</p>

	<p class="figure">
		<em class="bld"><a name="fig2"></a>Figure 2</em>&#8212;Linear discriminant boundary based on 20 hypothetical sample cases. <a href="graphics/verbyla_fig2_lg.gif">[view larger image - 16K]</a>
		<br />
		<br />
		 <a href="graphics/verbyla_fig2_lg.gif"><img src="graphics/verbyla_fig2.gif" alt="Graph showing linear discriminant boundary based on 20 hypothetical sample cases (explained within the text)." width="500" height="439" border="0" /></a>
	</p>

<br /><br />

	<p class="figure">
		<em class="bld"><a name="fig3"></a>Figure 3</em>&#8212;Random selection of half the original sample for model development and the remaining half for model validation. <a href="graphics/verbyla_fig3_lg.gif">[view larger image of graph below - 12K]</a>
		<br />
		<br />
		 <a href="graphics/verbyla_fig3a_lg.gif"><img src="graphics/verbyla_fig3a.gif" alt="Random selection of half the original sample for model development (explained within the text)." width="500" height="481" border="0" /></a>
		<br /><br /><a href="graphics/verbyla_fig3_lg.gif">[view larger image of graph below - 12K]</a>
		<br /><br />
		 <a href="graphics/verbyla_fig3b_lg.gif"><img src="graphics/verbyla_fig3b.gif" alt="Remaining half of random selection of original sample for model validation (explained within the text)." width="500" height="482" border="0" /></a>
	</p>

	<p>Fortunately, there are better statistical procedures for validating models. One method, called cross-validation (or the jacknife) has been used in development of soil-site models (Frank and others 1984; Harding and others 1985). Cross-validation yields <em class="ital">n</em> validation estimates of model accuracy (where <em class="ital">n</em> is the total number of sample cases).</p>
	<p>The cross-validation procedure is:</p>

	<ol>
  	<li>Exclude the <em class="ital">i</em>th (where <em class="ital">i</em> is initially one) sample case and reserve it for validation.</li>
  	<li>Develop the model with the remaining sample cases.</li>
  	<li>Estimate the model accuracy by testing it with the excluded sample case.</li>
  	<li>Return the excluded sample case, increment <em class="ital">i</em>, and repeat steps 1 through 4 until all sample cases have been used once for model testing.</li>
  </ol>

	<p>The mean of the <em class="ital">n</em> estimates from step 3 is a nearly unbiased estimate of the expected accuracy of the model (if we were to validate it with new data from the same population) (Efron 1983).</p>
	<p>A more precise estimate of expected model accuracy can be obtained using the bootstrap resampling procedure (Diaconis and Efron 1983; Efron 1983). The bootstrap resampling procedure is:</p>

	<ol>
  	<li>Randomly select &quot;with replacement&quot; <em class="ital">n</em> cases from the original sample. &quot;With replacement&quot; means that any sample case may be selected once, twice, several times, or not at all by this random selection process.</li>
  	<li>Develop the model with the selected sample cases.</li>
  	<li>Estimate the model accuracy by testing it with all sample cases that were not selected for model development in step 1.</li>
	</ol>

	<p>The process is repeated a large number of times (200-1,000). The expected model accuracy is then estimated as the weighted mean of the estimates from step 3.</p>
	<h2>COMPUTER SIMULATION</h2> 
	<p>I will present computer simulation results to illustrate these methods. My example uses a model developed with discriminant analysis; however, these resampling methods can be applied to most predictive statistical models such as linear regression and logit models.</p>
	<p>In this hypothetical example, we are interested in developing a model that predicts prime sites versus nonprime sites from soil factors. In the simulation, 30 sample cases (simulated forest stands) were generated with 10 predictor variables (simulated soil factors). The linear discriminant analysis procedure assumes normal distributions and equal variances, therefore the predictor variables were generated with these properties. Because each stand was randomly assigned to be either a prime site or nonprime site, the expected classification accuracy of the model was 50 percent (no better than flipping a coin).</p>
	<p>The simulation was repeated 1,000 times. In reality, the modeling process is performed only once. If we use the original sample cases to develop the model and then test the model with the same data (called the resubstitution method), we would have a biased estimate of the model's accuracy. On average, the model would appear to have a classification accuracy of 75 percent (<a href="#fig4">fig. 4</a>). Yet, the actual accuracy of the model would be expected to be only 50 percent if it were applied to new data.</p>
	<p>The same simulation was conducted using the cross-validation and bootstrap resampling methods to estimate model accuracy. Both methods produced nearly unbiased estimates of the expected accuracy of the model (<a href="#fig5">fig. 5</a>). The bootstrap method produced a more precise estimate and therefore is the best available method for estimating model accuracy (Efron 1983; Jain and others 1987).</p>

	<p class="figure">
		<em class="bld"><a name="fig4"></a>Figure 4</em>&#8212;Smoothed frequency distribution (N = 1,000 simulation trials) of resubstitution method estimates of model classification accuracy. <a href="graphics/verbyla_fig4_lg.gif">[view larger image - 12K]</a> <a href="graphics/verbyla_fig4_txt.html">[Text description of this graph]</a>
		<br />
		<br />
		 <a href="graphics/verbyla_fig4_lg.gif"><img src="graphics/verbyla_fig4.gif" alt="Graph showing smoothed frequency distribution of resubstitution method estimates of model classification accuracy." width="500" height="452" border="0" /></a>
	</p>

<br /><br />

	<p class="figure">
		<em class="bld"><a name="fig5"></a>Figure 5</em>&#8212;Smoothed frequency distribution (N = 1,000 simulation trials) of cross-validation and bootstrap estimates of model classification accuracy. <a href="graphics/verbyla_fig5_lg.gif">[view larger image - 16K]</a> <a href="graphics/verbyla_fig5_txt.html">[Text description of this graph]</a>
		<br />
		<br />
		 <a href="graphics/verbyla_fig5_lg.gif"><img src="graphics/verbyla_fig5.gif" alt="Graph showing smoothed frequency distribution of cross-validation and bootstrap estimates of model classification accuracy." width="500" height="455" border="0" /></a>
	</p>

	<h2>CONCLUSIONS</h2> 
	<p>Predictive statistical models can be biased. The prediction bias potential is especially high if sample sizes are small and many candidate predictor variables are tested for possible inclusion in the model. Because of the potential for prediction bias, predictive models must be validated. Resampling procedures such as cross-validation and the bootstrap require no new data and are relatively simple to implement (Verbyla 1989). There is no excuse not to use them.</p>
	<p>A rational modeling approach is needed. The reliability and biological significance of predictive statistical models should be questioned (Rexstad 1988; Verbyla 1986). I believe that after models are developed, they should next be validated using a resampling procedure such as cross-validation or the bootstrap. The &quot;acid test&quot; should then be field validation to determine how well they predict under new conditions.</p>
	<h2>ACKNOWLEDGMENTS</h2> 
	<p>I thank C. T. Smith for reviewing the manuscript and offering constructive suggestions.</p>
	<h2>REFERENCES</h2>
	<p class="ref">
		<strong>Carmean, W. H.</strong> 1975. Forest site quality evaluation in the United States. Advances in Agronomy. <strong>27</strong>: 209-269.
	</p>
	<p class="ref">
		<strong>Diaconis, P.; Efron, B.</strong> 1983. Computer-intensive methods in statistics. Scientific American. <strong>248</strong>: 116-127.
	</p>
	<p class="ref">
		<strong>Efron, B.</strong> 1983. Estimating the error rate of a prediction rule: Improvement on cross-validation. Journal of the American Statistical Assocation. <strong>78</strong>: 316-331.
	</p>
	<p class="ref">
		<strong>Frank, P. S., Jr.; Hicks, R. R.; Harner, E. J., Jr.</strong> 1984. Biomass predicted by soil-site factors: a case study in north central West Virginia. Canadian Journal of Forest Research. <strong>14</strong>: 137-140.
	</p>
	<p class="ref">
		<strong>Grey, D. C.</strong> 1983. The evaluation of site factor studies. South African Forestry Journal. <strong>127</strong>: 19-22.
	</p>
	<p class="ref">
		<strong>Harding, R. B.; Grigal, D. F.; White, E. H.</strong> 1985. Site quality evaluation for white spruce plantations using discriminant analysis. Soil Science Society of America Journal. <strong>49</strong>: 229-232.
	</p>
	<p class="ref">
		<strong>Jain, A. K.; Dubes, R. C.; Chen, C. C.</strong> 1987. Bootstrap techniques for error estimation. IEEE Transactions of Pattern Analysis. <strong>9</strong>: 628-633.
	</p>
	<p class="ref">
		<strong>McQuilkin, R. A.</strong> 1976. The necessity of independent testing of soil-site equations. Soil Science Society of America Journal. <strong>40</strong>: 783-785.
	</p>
	<p class="ref">
		<strong>Rexstad, E. A.; Miller, D. D.; Flather, C. H.; Anderson, E. M.; Hupp, J. W.; Anderson, D. R.</strong> 1988. Questionable multivariate statistical inference in wildlife habitat and community studies. Journal of Wildlife Management. <strong>52</strong>: 794-798.
	</p>
	<p class="ref">
		<strong>Verbyla, D. L.</strong> 1986. Potential prediction bias in regression and discriminant analysis. Canadian Journal of Forest Research. <strong>16</strong>: 1255-1257.
	</p>
	<p class="ref">
		<strong>Verbyla, D. L.; Litvaitis, J. A.</strong> 1989. Resampling methods for evaluating classification accuracy of wildlife habitat models. Environmental Management. <strong>13</strong>: 783-787.</p>
	<p class="notes">Paper presented at the Symposium on Management and Productivity of Western-Montane Forest Soils, Boise, ID, April 10-12, 1990.</p>
	<p class="notes">David L. Verbyla is Visiting Assistant Professor, Department of Forest Resources, University of Idaho, Moscow, ID 83843.</p>

</div>
<!-- END PUBLICATION -->
<?php
require("http://forest.moscowfsl.wsu.edu/smp/solo/shared/footer.php");
?>
