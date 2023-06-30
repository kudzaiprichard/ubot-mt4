//+------------------------------------------------------------------+
//|                                                        Trend.mqh |
//|                                      Copyright 2022, U Bot Corp. |
//|                                             https://www.ubot.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, U Bot Corp."
#property link      "https://www.ubot.com"
#property version   "1.00"
#property strict
class Trend{
private:
   string trendMagic;
   double trendMagicBuyHandle;
   double trendMagicSellHandle;
   double bufferUp[1000];
   double bufferDn[1000];
   
   int CCI;
   int ATR;
public:
   Trend();
   ~Trend();
   bool trend();
   bool ubotTrend(int timeframe);
   bool emaTrend(int timeframe);
   int combine();
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Trend::Trend(){
   Trend::trendMagic = "Ubot//ubot-trend.ex4";
   Trend::CCI = 50;
   Trend::ATR = 5;
}
Trend::~Trend(){}
//+------------------------------------------------------------------+

bool Trend::trend(){
   Trend::trendMagicBuyHandle  =  NormalizeDouble(iCustom(_Symbol,PERIOD_M15,Trend::trendMagic,0,0),_Digits);
  
   if(Trend::trendMagicBuyHandle<20000){
      Comment("BUY\n", "Trend :", Trend::trendMagicBuyHandle);
      return(true);
   }
   else{//Trend::trendMagicBuyHandle>20000
      Comment("SELL\n", "Trend :", Trend::trendMagicBuyHandle);
      return(false);
   }
}

bool Trend::ubotTrend(int timeframe){
   double thisCCI;
   double lastCCI;

   //int counted_bars = IndicatorCounted();
   //if (counted_bars < 0) return (false);
   //if (counted_bars > 0) counted_bars--;
   //int limit = Bars - counted_bars;  
   //TODO: Why use limit as shift
   for (int shift = 2; shift >= 0; shift--){//for (int shift = limit ; shift >= 0; shift--)
      ArrayResize(bufferUp, shift);
      ArrayResize(bufferDn, shift);
      
      thisCCI = iCCI(_Symbol,timeframe, CCI, PRICE_TYPICAL, shift);
      lastCCI = iCCI(_Symbol, timeframe, CCI, PRICE_TYPICAL, shift + 1);

      if (thisCCI >= 0 && lastCCI < 0 ) bufferUp[shift + 1] = bufferDn[shift + 1];
      if (thisCCI <= 0 && lastCCI > 0) bufferDn[shift + 1] = bufferUp[shift + 1];

      if (thisCCI >= 0){
         //Comment("Up trend");
         return(true);
      }
      
      else{
         //Comment("Down trend");
         return(false);
      } 
   }
   return(NULL);
}

bool Trend::emaTrend(int timeframe){
   double emaHandle50  =  NormalizeDouble(iMA(_Symbol,timeframe,50,0,MODE_EMA,PRICE_CLOSE,0),_Digits);
   double emaHandle200  =  NormalizeDouble(iMA(_Symbol,timeframe,200,0,MODE_EMA,PRICE_CLOSE,0),_Digits);
   
   if(emaHandle50 > emaHandle200){ //Up trend
      return(true); 
   }
   else{
      return(false);
   }
}

int Trend::combine(){
   double thisCCI;
   double lastCCI;
   double emaHandle50  =  NormalizeDouble(iMA(_Symbol,PERIOD_M15,50,0,MODE_EMA,PRICE_CLOSE,0),_Digits);
   double emaHandle200  =  NormalizeDouble(iMA(_Symbol,PERIOD_M15,200,0,MODE_EMA,PRICE_CLOSE,0),_Digits);

   for (int shift = 2; shift >= 0; shift--){//for (int shift = limit ; shift >= 0; shift--)
      ArrayResize(bufferUp, shift);
      ArrayResize(bufferDn, shift);
      
      thisCCI = iCCI(_Symbol,PERIOD_M15, CCI, PRICE_TYPICAL, shift);
      lastCCI = iCCI(_Symbol, PERIOD_M15, CCI, PRICE_TYPICAL, shift + 1);

      if (thisCCI >= 0 && lastCCI < 0 ) bufferUp[shift + 1] = bufferDn[shift + 1];
      if (thisCCI <= 0 && lastCCI > 0) bufferDn[shift + 1] = bufferUp[shift + 1];

      if (thisCCI >= 0 && emaHandle50 > emaHandle200){
         Comment("Up trend");
         return(0);
      }
      
      else if(thisCCI < 0 && emaHandle50 < emaHandle200){
         Comment("Down trend");
         return(1);
      }
      
      else{Comment("NOTHING");} 
   }
   return(2);
}