# cfhi_feature_ui.R
# UI module for Consumer Financial Health Index (CFHI)

cfhi_feature_ui <- function(id) {
  ns <- NS(id)
  tagList(
    # Top row with current CFHI card and summary stats
    tags$div(
      style = "display:flex; gap:20px; align-items:stretch; flex-wrap: wrap; margin-bottom:20px;",
      
      # Current CHFI card - larger and more prominent
      tags$div(
        style = "flex: 1 1 300px; 
                 border:2px solid #e5e7eb; 
                 border-radius:16px; 
                 padding:24px; 
                 background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                 box-shadow: 0 10px 25px rgba(102, 126, 234, 0.3);
                 color: white;",
        tags$div(
          style="font-size:14px; 
                 color:rgba(255,255,255,0.9); 
                 text-transform:uppercase; 
                 letter-spacing:0.1em; 
                 font-weight:500;", 
          "Current CFHI"
        ),
        tags$div(
          id = ns("current_label"), 
          style="font-size:48px; 
                 font-weight:800; 
                 color:#ffffff; 
                 margin-top:8px; 
                 margin-bottom:4px;
                 text-shadow: 2px 2px 4px rgba(0,0,0,0.2);", 
          "—"
        ),
        tags$div(
          id = ns("current_sub"), 
          style="font-size:13px; 
                 color:rgba(255,255,255,0.85); 
                 font-weight:500;", 
          "Latest available month"
        ),
        
        # Summary stats in the same card
        uiOutput(ns("summary_stats"))
      ),
      
      # Controls card - cleaner layout
      tags$div(
        style = "flex: 2 1 500px; 
                 border:2px solid #e5e7eb; 
                 border-radius:16px; 
                 padding:24px;
                 background:#ffffff;
                 box-shadow: 0 4px 15px rgba(0,0,0,0.05);",
        
        tags$h4(
          style="margin-top:0; margin-bottom:20px; color:#1f2937; font-weight:600;",
          "📊 Customize Your View"
        ),
        
        fluidRow(
          column(
            width = 6,
            tags$div(
              style="margin-bottom:12px;",
              uiOutput(ns("date_range_ui"))
            )
          ),
          column(
            width = 3,
            tags$div(
              style="margin-bottom:12px;",
              numericInput(
                ns("smooth_k"), 
                "Smoothing (months)", 
                value = 3, 
                min = 1, 
                max = 24, 
                step = 1
              )
            )
          ),
          column(
            width = 3,
            tags$div(
              style="margin-bottom:12px;",
              selectInput(
                ns("show_series"), 
                "Display Mode",
                choices = c(
                  "CFHI Only" = "cfhi_only",
                  "CFHI + Components" = "cfhi_plus"
                ),
                selected = "cfhi_only"
              )
            )
          )
        ),
        
        # Legend for health zones
        tags$div(
          style="margin-top:16px; 
                 padding:12px; 
                 background:#f9fafb; 
                 border-radius:8px;
                 border-left: 4px solid #3b82f6;",
          tags$div(
            style="font-size:12px; font-weight:600; color:#374151; margin-bottom:8px;",
            "Health Zone Guide:"
          ),
          tags$div(
            style="display:flex; gap:16px; flex-wrap:wrap; font-size:11px;",
            tags$span(style="color:#10b981; font-weight:600;", "● 90-100: Excellent"),
            tags$span(style="color:#84cc16; font-weight:600;", "● 70-90: Good"),
            tags$span(style="color:#eab308; font-weight:600;", "● 50-70: Fair"),
            tags$span(style="color:#f97316; font-weight:600;", "● 30-50: Poor"),
            tags$span(style="color:#ef4444; font-weight:600;", "● 0-30: Critical")
          )
        )
      )
    ),
    
    # Interactive Plot
    tags$div(
      style="background:#ffffff; 
             border-radius:16px; 
             padding:20px; 
             box-shadow: 0 4px 15px rgba(0,0,0,0.05);
             border:2px solid #e5e7eb;",
      plotlyOutput(ns("cfhi_plot"), height = "600px")
    ),
    
    br(),
    
    # Enhanced footnote
    tags$div(
      style = "background:#f9fafb; 
               padding:16px; 
               border-radius:12px; 
               border-left:4px solid #3b82f6;
               margin-top:16px;",
      tags$p(
        style = "font-size:12px; 
                 color:#64748b; 
                 margin:0; 
                 line-height:1.6;",
        tags$strong(style="color:#1f2937;", "About CFHI: "),
        "The Consumer Financial Health Index is an equal-weighted composite of four normalized economic indicators: ",
        tags$span(style="color:#8b5cf6; font-weight:600;", "Savings Rate ↑"), ", ",
        tags$span(style="color:#06b6d4; font-weight:600;", "Wage Growth ↑"), ", ",
        tags$span(style="color:#f59e0b; font-weight:600;", "Inflation ↓"), ", and ",
        tags$span(style="color:#ec4899; font-weight:600;", "Borrowing Rate ↓"), ". ",
        "The index is rebased relative to January 2000 = 100. ",
        tags$em("Higher values indicate better financial health.")
      )
    )
  )
}
