# ===============================================================================
# FINDINGS TAB - KEY INSIGHTS FROM CFHI ANALYSIS
# ===============================================================================

findings_tab <- tabItem(
  tabName = "findings",
  
  fluidRow(
    column(12, align = "center",
      h2("Key Findings & Analysis", 
         style = "font-family: 'Trebuchet MS', sans-serif; font-size: 32px; font-weight: bold; color: #2c3e50; margin-bottom: 20px;")
    )
  ),
  
  fluidRow(
    valueBoxOutput("findings_peak", width = 3),
    valueBoxOutput("findings_trough", width = 3),
    valueBoxOutput("findings_current", width = 3),
    valueBoxOutput("findings_mean", width = 3)
  ),
  
  fluidRow(
    box(
      width = 12,
      title = "Finding 1: Pre-Crisis Financial Deterioration (2007)",
      status = "danger",
      solidHeader = TRUE,
      
      HTML("
        <div style='padding: 15px;'>
          <h4 style='color: #c0392b; margin-top: 0;'>Historical Minimum Observed in May 2007</h4>
          
          <div style='background: #fef5e7; border-left: 4px solid #f39c12; padding: 15px; margin: 15px 0; border-radius: 4px;'>
            <p style='margin: 0; font-size: 15px; color: #7d6608;'>
              <strong>Key Observation:</strong> Household financial health reached its lowest recorded value of 17.90 in May 2007, 
              several months prior to the onset of the stock market decline and official recession declaration.
            </p>
          </div>
          
          <h5 style='color: #2c3e50;'>Contributing Factors</h5>
          <ul style='font-size: 14px; color: #34495e; line-height: 1.8;'>
            <li><strong>Elevated Interest Rates:</strong> Federal funds rate reached 5.25%, representing the highest level 
                in the dataset and substantially increasing debt service costs for mortgages and consumer credit.</li>
            <li><strong>Negative Personal Savings Rate:</strong> Aggregate household savings declined to -1.7%, 
                indicating consumption expenditures exceeded disposable income.</li>
            <li><strong>Subdued Wage Growth:</strong> Real wage increases remained minimal at approximately 0.5-0.7% year-over-year, 
                insufficient to offset rising living costs.</li>
            <li><strong>Household Leverage Expansion:</strong> Elevated mortgage debt levels created vulnerability 
                to subsequent housing market corrections.</li>
          </ul>
          
          <div style='background: #ebf5fb; border-left: 4px solid #3498db; padding: 15px; margin: 15px 0; border-radius: 4px;'>
            <p style='margin: 0; font-size: 14px; color: #1b4f72;'>
              <strong>Analytical Insight:</strong> The CFHI exhibited leading indicator properties, 
              signaling household financial stress prior to broader macroeconomic deterioration becoming evident in equity markets.
            </p>
          </div>
        </div>
      ")
    )
  ),
  
  fluidRow(
    box(
      width = 12,
      title = "Finding 2: Pandemic-Era Financial Position Peak (2020)",
      status = "success",
      solidHeader = TRUE,
      
      HTML("
        <div style='padding: 15px;'>
          <h4 style='color: #27ae60; margin-top: 0;'>Maximum Index Value Recorded in April 2020</h4>
          
          <div style='background: #eafaf1; border-left: 4px solid #27ae60; padding: 15px; margin: 15px 0; border-radius: 4px;'>
            <p style='margin: 0; font-size: 15px; color: #145a32;'>
              <strong>Key Observation:</strong> Despite significant labor market disruption and economic contraction, 
              the CFHI reached its all-time maximum value of 93.34 in April 2020.
            </p>
          </div>
          
          <h5 style='color: #2c3e50;'>Structural Drivers</h5>
          <ul style='font-size: 14px; color: #34495e; line-height: 1.8;'>
            <li><strong>Zero Lower Bound Monetary Policy:</strong> Federal Reserve reduced the target rate to 0-0.25%, 
                minimizing borrowing costs and enabling debt refinancing at favorable terms.</li>
            <li><strong>Constrained Consumption Patterns:</strong> Public health restrictions limited discretionary spending 
                on services and travel, mechanically increasing the savings rate.</li>
            <li><strong>Fiscal Transfer Programs:</strong> Direct payments, enhanced unemployment benefits, 
                and Paycheck Protection Program funding temporarily supplemented household balance sheets.</li>
            <li><strong>Transitory Price Stability:</strong> Demand-side shocks initially suppressed inflationary pressures 
                during the acute phase of economic contraction.</li>
          </ul>
          
          <div style='background: #fef9e7; border-left: 4px solid #f39c12; padding: 15px; margin: 15px 0; border-radius: 4px;'>
            <p style='margin: 0; font-size: 14px; color: #7d6608;'>
              <strong>Methodological Note:</strong> The observed improvement represents an exogenous constraint on spending 
              rather than income growth, rendering this peak a temporary artifact of pandemic-specific conditions. 
              Subsequent periods exhibited normalization as fiscal support expired and inflation accelerated.
            </p>
          </div>
        </div>
      ")
    )
  ),
  
  fluidRow(
    box(
      width = 12,
      title = "Finding 3: Contemporary Affordability Pressures (2024-2025)",
      status = "warning",
      solidHeader = TRUE,
      
      HTML("
        <div style='padding: 15px;'>
          <h4 style='color: #d68910; margin-top: 0;'>Current Index Level Approximates Pre-Recession Conditions</h4>
          
          <div style='background: #fef5e7; border-left: 4px solid #e67e22; padding: 15px; margin: 15px 0; border-radius: 4px;'>
            <p style='margin: 0; font-size: 15px; color: #7d6608;'>
              <strong>Current Assessment:</strong> As of August 2025, the CFHI stands at 28.38, 
              marginally above the 2007 crisis minimum and 70% below the 2020 maximum.
            </p>
          </div>
          
          <h5 style='color: #2c3e50;'>Primary Determinants</h5>
          <ul style='font-size: 14px; color: #34495e; line-height: 1.8;'>
            <li><strong>Post-Pandemic Inflation Episode:</strong> Consumer price increases peaked near 7-9% during 2021-2022, 
                eroding real purchasing power despite nominal wage adjustments.</li>
            <li><strong>Monetary Policy Tightening:</strong> Federal funds rate increased to 4.33% from near-zero levels, 
                substantially raising costs for mortgage origination, auto financing, and revolving credit.</li>
            <li><strong>Savings Rate Normalization:</strong> Personal savings declined to 4.6% as pandemic-era accumulations 
                were depleted to maintain consumption amid rising prices.</li>
            <li><strong>Modest Real Wage Growth:</strong> Year-over-year wage increases of 1.4% remain insufficient 
                to offset elevated costs for housing, food, and energy.</li>
          </ul>
          
          <div style='background: #fadbd8; border-left: 4px solid #c0392b; padding: 15px; margin: 15px 0; border-radius: 4px;'>
            <p style='margin: 0; font-size: 14px; color: #78281f;'>
              <strong>Risk Profile:</strong> Current CFHI values parallel pre-2008 crisis levels. 
              While this does not constitute a forecasting signal for financial market instability, 
              it indicates persistent stress on household balance sheets and constrained consumption capacity.
            </p>
          </div>
        </div>
      ")
    )
  ),
  
  fluidRow(
    box(
      width = 12,
      title = "Finding 4: Limited Stock Market Correlation with Household Financial Health",
      status = "info",
      solidHeader = TRUE,
      
      HTML("
        <div style='padding: 15px;'>
          <h4 style='color: #2980b9; margin-top: 0;'>Regression Analysis Reveals Minimal Equity Market Impact</h4>
          
          <div style='background: #ebf5fb; border-left: 4px solid #3498db; padding: 15px; margin: 15px 0; border-radius: 4px;'>
            <p style='margin: 0; font-size: 15px; color: #1b4f72;'>
              <strong>Statistical Finding:</strong> Multiple regression analysis controlling for Federal Reserve policy indicates 
              that a 1,000-point increase in the S&P 500 index corresponds to approximately 0.7-point increase in CFHI, 
              representing less than 1% of the index range.
            </p>
          </div>
          
          <h5 style='color: #2c3e50;'>Explanatory Mechanisms</h5>
          <ul style='font-size: 14px; color: #34495e; line-height: 1.8;'>
            <li><strong>Wealth Distribution Asymmetry:</strong> The wealthiest decile controls approximately 90% of equity holdings. 
                Capital gains accrue disproportionately to high-net-worth households with minimal transmission to median households.</li>
            <li><strong>Primary CFHI Determinants:</strong> Index composition weights direct household factors including 
                wage growth (normalized component: 47.99), inflation exposure (28.42), interest rate burdens (18.94), 
                and savings capacity (18.16).</li>
            <li><strong>Monetary Policy Dominance:</strong> Federal funds rate changes demonstrate approximately 5× larger 
                impact coefficients relative to equity market movements in explaining CFHI variation.</li>
          </ul>
          
          <div style='background: #fef9e7; border-left: 4px solid #16a085; padding: 15px; margin: 15px 0; border-radius: 4px;'>
            <p style='margin: 0; font-size: 14px; color: #0e6655;'>
              <strong>Policy Consideration:</strong> Exclusive focus on equity market performance as a proxy for economic welfare 
              fails to capture the material conditions facing households without substantial financial asset holdings. 
              Wage dynamics and borrowing costs constitute more relevant determinants of financial health across income distributions.
            </p>
          </div>
        </div>
      ")
    )
  ),
  
  fluidRow(
    box(
      width = 12,
      title = "Methodology & Data Quality",
      status = "primary",
      solidHeader = TRUE,
      collapsible = TRUE,
      collapsed = FALSE,
      
      HTML("
        <div style='padding: 15px; font-size: 14px; color: #34495e;'>
          <h5 style='color: #2c3e50;'>Data Sources</h5>
          <ul style='line-height: 1.8;'>
            <li><strong>Personal Savings Rate:</strong> Bureau of Economic Analysis (BEA), monthly frequency</li>
            <li><strong>Average Hourly Earnings Growth:</strong> Bureau of Labor Statistics (BLS), seasonally adjusted</li>
            <li><strong>Consumer Price Index (CPI-U):</strong> Bureau of Labor Statistics (BLS), all items urban consumers</li>
            <li><strong>Federal Funds Effective Rate:</strong> Federal Reserve Economic Data (FRED), daily aggregated to monthly</li>
          </ul>
          
          <h5 style='color: #2c3e50; margin-top: 20px;'>Index Construction</h5>
          <p style='margin: 10px 0;'>
            <code style='background: #ecf0f1; padding: 3px 8px; border-radius: 3px; font-size: 13px;'>
              CFHI = (S* + W* + I* + R*) / 4
            </code>
          </p>
          <ul style='line-height: 1.8;'>
            <li><strong>S* (Savings):</strong> Min-max normalization to 0-100 scale, where 100 represents maximum observed savings rate</li>
            <li><strong>W* (Wages):</strong> Min-max normalization to 0-100 scale, where 100 represents maximum observed wage growth</li>
            <li><strong>I* (Inflation):</strong> Inverted min-max normalization, where 100 corresponds to minimum observed inflation</li>
            <li><strong>R* (Interest Rates):</strong> Inverted min-max normalization, where 100 corresponds to minimum observed rates</li>
          </ul>
          
          <p style='margin-top: 15px; padding: 12px; background: #eaecee; border-radius: 4px;'>
            <strong>Interpretation:</strong> CFHI theoretically ranges from 0 (all components at historical extremes unfavorable to households) 
            to 100 (all components at historical optima). Empirically observed range: 17.90 (May 2007) to 93.34 (April 2020). 
            Equal weighting reflects assumption of comparable importance across dimensions.
          </p>
          
          <h5 style='color: #2c3e50; margin-top: 20px;'>Limitations</h5>
          <ul style='line-height: 1.8;'>
            <li>Utilizes population-level aggregates; does not capture distributional heterogeneity or within-group inequality</li>
            <li>Housing cost burden excluded as direct component; effects captured indirectly through savings rate compression</li>
            <li>Rolling normalization implies index recalibration as historical extremes shift with new observations</li>
            <li>Equal weighting scheme lacks empirical validation; alternative specifications may yield differential component importance</li>
            <li>Does not incorporate household debt levels, wealth effects, or asset price appreciation beyond interest rate channels</li>
          </ul>
        </div>
      ")
    )
  )
)
