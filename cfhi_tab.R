tabItem(
  tabName = "cfhi",
  
  # Hero section
  tags$div(
    style = "background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
             padding: 40px 30px;
             border-radius: 16px;
             margin-bottom: 30px;
             box-shadow: 0 10px 30px rgba(102, 126, 234, 0.3);",
    tags$h1(
      style = "color: white; 
               margin: 0 0 12px 0; 
               font-size: 36px; 
               font-weight: 700;
               text-shadow: 2px 2px 4px rgba(0,0,0,0.2);",
      "📊 Consumer Financial Health Index (CFHI)"
    ),
    tags$p(
      style = "color: rgba(255,255,255,0.95); 
               font-size: 18px; 
               margin: 0;
               font-weight: 400;",
      "Interactive analysis of consumer financial health through economic indicators"
    )
  ),
  
  # Financial Health Scale Guide
  tags$div(
    style = "background: white;
             padding: 24px;
             border-radius: 16px;
             margin-bottom: 30px;
             box-shadow: 0 4px 15px rgba(0,0,0,0.05);
             border: 2px solid #e5e7eb;",
    tags$h3(
      style = "margin-top: 0; 
               margin-bottom: 20px; 
               color: #1f2937; 
               font-weight: 600;",
      "Understanding Financial Health Scores"
    ),
    
    # Gradient color bar with labels
    tags$div(
      style = "position: relative; margin-bottom: 20px;",
      tags$div(
        style = "
          height: 40px;
          background: linear-gradient(to right, 
                      #ef4444 0%, 
                      #f97316 20%, 
                      #eab308 40%, 
                      #84cc16 60%, 
                      #10b981 80%, 
                      #10b981 100%);
          border-radius: 20px;
          box-shadow: 0 4px 10px rgba(0,0,0,0.1);
        "
      ),
      # Score markers
      tags$div(
        style = "display: flex; 
                 justify-content: space-between; 
                 margin-top: 8px;
                 font-size: 12px;
                 font-weight: 600;
                 color: #6b7280;",
        tags$span("0"),
        tags$span("30"),
        tags$span("50"),
        tags$span("70"),
        tags$span("90"),
        tags$span("100")
      )
    ),
    
    # Legend cards with icons
    fluidRow(
      column(
        width = 4,
        offset = 1,
        tags$div(
          style = "
            border: 3px solid #ef4444;
            border-radius: 12px;
            padding: 16px;
            text-align: center;
            background: linear-gradient(135deg, #fef2f2 0%, #fee2e2 100%);
            box-shadow: 0 2px 8px rgba(239, 68, 68, 0.2);
            height: 100%;",
          tags$div(style = "font-size: 32px; margin-bottom: 8px;", "⚠️"),
          tags$div(style = "font-weight: 700; font-size: 18px; color: #dc2626; margin-bottom: 4px;", "0 - 30"),
          tags$div(style = "font-weight: 600; color: #991b1b;", "Critical"),
          tags$div(style = "font-size: 11px; color: #7f1d1d; margin-top: 6px;", "Immediate action needed")
        )
      ),
      column(
        width = 2,
        tags$div(
          style = "
            border: 3px solid #f97316;
            border-radius: 12px;
            padding: 16px;
            text-align: center;
            background: linear-gradient(135deg, #fff7ed 0%, #ffedd5 100%);
            box-shadow: 0 2px 8px rgba(249, 115, 22, 0.2);
            height: 100%;",
          tags$div(style = "font-size: 28px; margin-bottom: 8px;", "⚡"),
          tags$div(style = "font-weight: 700; font-size: 16px; color: #ea580c; margin-bottom: 4px;", "30 - 50"),
          tags$div(style = "font-weight: 600; color: #c2410c;", "Poor"),
          tags$div(style = "font-size: 11px; color: #9a3412; margin-top: 6px;", "Needs improvement")
        )
      ),
      column(
        width = 2,
        tags$div(
          style = "
            border: 3px solid #eab308;
            border-radius: 12px;
            padding: 16px;
            text-align: center;
            background: linear-gradient(135deg, #fefce8 0%, #fef9c3 100%);
            box-shadow: 0 2px 8px rgba(234, 179, 8, 0.2);
            height: 100%;",
          tags$div(style = "font-size: 28px; margin-bottom: 8px;", "📊"),
          tags$div(style = "font-weight: 700; font-size: 16px; color: #ca8a04; margin-bottom: 4px;", "50 - 70"),
          tags$div(style = "font-weight: 600; color: #a16207;", "Fair"),
          tags$div(style = "font-size: 11px; color: #854d0e; margin-top: 6px;", "Room to grow")
        )
      ),
      column(
        width = 3,
        tags$div(
          style = "
            border: 3px solid #10b981;
            border-radius: 12px;
            padding: 16px;
            text-align: center;
            background: linear-gradient(135deg, #f0fdf4 0%, #dcfce7 100%);
            box-shadow: 0 2px 8px rgba(16, 185, 129, 0.2);
            height: 100%;",
          tags$div(style = "font-size: 32px; margin-bottom: 8px;", "✅"),
          tags$div(style = "font-weight: 700; font-size: 18px; color: #059669; margin-bottom: 4px;", "70 - 100"),
          tags$div(style = "font-weight: 600; color: #047857;", "Good to Excellent"),
          tags$div(style = "font-size: 11px; color: #065f46; margin-top: 6px;", "Strong financial health")
        )
      )
    )
  ),
  
  br(),
  
  # === CFHI feature panel ===
  shinydashboard::box(
    title = "📈 Interactive CFHI Analysis",
    width = 12, 
    status = "primary", 
    solidHeader = TRUE,
    cfhi_feature_ui("cfhi")
  )
)
