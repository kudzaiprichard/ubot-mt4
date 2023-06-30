//+------------------------------------------------------------------+
//|                                                        Chart.mqh |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Software Corp."
#property link      "https://www.mql4.com"
#property version   "1.00"
#property strict
class Chart
  {
private:

public:
                     Chart();
                    ~Chart();
                    bool SetChartProperties();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Chart::Chart(){}
Chart::~Chart(){}
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
bool Chart::SetChartProperties(){

   ResetLastError();
   if(!ChartSetInteger(0,CHART_COLOR_BACKGROUND,0,clrWhite) 
   || !ChartSetInteger(0,CHART_COLOR_FOREGROUND,0,clrBlack)
   || !ChartSetInteger(0,CHART_COLOR_CANDLE_BEAR,0,clrBlack)
   || !ChartSetInteger(0,CHART_COLOR_CANDLE_BULL,0,clrWhite)
   || !ChartSetInteger(0,CHART_COLOR_CHART_LINE,0,clrBlack)
   || !ChartSetInteger(0,CHART_COLOR_CHART_DOWN,0,clrBlack)
   || !ChartSetInteger(0,CHART_COLOR_CHART_UP,0,clrBlack)
   || !ChartSetInteger(0,CHART_COLOR_ASK,0,clrOrangeRed)
   || !ChartSetInteger(0,CHART_COLOR_STOP_LEVEL,0,clrOrangeRed)
   || !ChartSetInteger(0,CHART_COLOR_VOLUME,0,clrGreen)
   || !ChartSetInteger(0,CHART_SHOW_ASK_LINE,0,true)
   || !ChartSetInteger(0,CHART_SHOW_BID_LINE,0,true)
   || !ChartSetInteger(0,CHART_SHOW_GRID,0,false)
   || !ChartSetInteger(0,CHART_SHOW_PERIOD_SEP,0,true)
   || !ChartSetInteger(0,CHART_SHIFT,0,true)
   )
     {
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
     }

   return(true);
  }
//+------------------------------------------------------------------+