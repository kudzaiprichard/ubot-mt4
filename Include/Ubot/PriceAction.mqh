//+------------------------------------------------------------------+
//|                                                  PriceAction.mqh |
//|                                          Copyright 2022, Intela. |
//|                                             https://www.ubot.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Intela."
#property link      "https://www.ubot.com"
#property version   "1.00"

#include <Ubot/TrendHiLo.mqh>

class PriceAction{
private:
   string h0;
   string h0S;
   string h1;
   string h1S;
   string l0;
   string l0S;
   string l1;
   string l1S;
   
   
   double yersterdayHigh;
   double currentHigh;
   
   double currentLow;
   double yersterdayLow;
   
   datetime currentTime;
   datetime yersterdayTime;
   datetime time;
   
   void drawAndMoveLine(string firstName, string secondName, color clr, string label);
public:
   PriceAction();
   ~PriceAction();
   void drawLowAndHighOfDay();
   double getCurrentHigh();
   double getCurrentLow();
   double getYersterdayHigh();
   double getYersterdayLow();
   void trendLines(int inpStart = 10, int inpLength = 50);
   void PriceAction::supportRessistance();
   void func();
};
//+------------------------------------------------------------------+
//|Constructor                                                       |
//+------------------------------------------------------------------+
PriceAction::PriceAction(){

   PriceAction::h0="H0"; 
   PriceAction::h0S = "H0Str"; 
   
   PriceAction::h1="H1"; 
   PriceAction::h1S = "H1Str"; 
   
   PriceAction::l0="L0"; 
   PriceAction::l0S = "L0Str"; 
   
   PriceAction::l1="L1"; 
   PriceAction::l1S = "L1Str";
}

PriceAction::~PriceAction(){}
//+------------------------------------------------------------------+

//Function to draw lines
//+------------------------------------------------------------------+
void PriceAction::drawAndMoveLine(string firstName, string secondName, color clr, string label){

   if(ObjectCreate(0, firstName, OBJ_HLINE, 0, 0, 0)){
      ObjectSetInteger(0, firstName, OBJPROP_COLOR, 0, clr);
   }
    
   if(ObjectCreate(0, secondName, OBJ_TEXT, 0, 0, 0)){
      ObjectSetText(secondName, label, 12, NULL, clr);
      ObjectSetInteger(0, secondName, OBJPROP_ANCHOR, ANCHOR_CENTER);
   }
  
   ObjectMove(0, h0, 0, PriceAction::currentTime, PriceAction::currentHigh);
   ObjectMove(0, h1, 0, PriceAction::yersterdayTime, PriceAction::yersterdayHigh);
   
   ObjectMove(0, l0, 0, PriceAction::currentTime, PriceAction::currentLow);
   ObjectMove(0, l1, 0, PriceAction::yersterdayTime, PriceAction::yersterdayLow);
         
   ObjectMove(0, h0S, 0, PriceAction::time, PriceAction::currentHigh);
   ObjectMove(0, h1S, 0, PriceAction::time, PriceAction::yersterdayHigh);
   
   ObjectMove(0, l0S, 0, PriceAction::time, PriceAction::currentLow);
   ObjectMove(0, l1S, 0, PriceAction::time, PriceAction::yersterdayLow);
}
//+------------------------------------------------------------------+
//draw high and low of current and yersterday date
//+------------------------------------------------------------------+
void PriceAction::drawLowAndHighOfDay(){
   PriceAction::currentHigh = iHigh(_Symbol, PERIOD_D1, 0); 
   PriceAction::yersterdayHigh = iHigh(_Symbol, PERIOD_D1, 1);
   
   PriceAction::currentLow = iLow(_Symbol, PERIOD_D1, 0);  
   PriceAction::yersterdayLow = iLow(_Symbol, PERIOD_D1, 1);
              
   PriceAction::currentTime = iTime(_Symbol, PERIOD_D1, 0); 
   PriceAction::yersterdayTime = iTime(_Symbol, PERIOD_D1, 1); 
   PriceAction::time = Time[0];
    
   PriceAction::drawAndMoveLine(PriceAction::h0, PriceAction::h0S, clrRed, "today High");
   PriceAction::drawAndMoveLine(PriceAction::l0, PriceAction::l0S, clrRed, "today Low");
   PriceAction::drawAndMoveLine(PriceAction::h1, PriceAction::h1S, clrGreen, "yesterday High");
   PriceAction::drawAndMoveLine(PriceAction::l1, PriceAction::l1S, clrGreen, "yesterday Low");
}
//+------------------------------------------------------------------+
//Get current high
//+------------------------------------------------------------------+
double PriceAction::getCurrentHigh(){
   return iHigh(_Symbol, PERIOD_D1, 0);
}
//+------------------------------------------------------------------+
//Get current low
//+------------------------------------------------------------------+
double PriceAction::getCurrentLow(){
   return iLow(_Symbol, PERIOD_D1, 0);
}
//+------------------------------------------------------------------+
//Get yersterday high
//+------------------------------------------------------------------+
double PriceAction::getYersterdayHigh(){  
   return iHigh(_Symbol, PERIOD_D1, 1);
}
//+------------------------------------------------------------------+
//Get yersterday low
//+------------------------------------------------------------------+
double PriceAction::getYersterdayLow(){
   return iLow(_Symbol, PERIOD_D1, 1);
}
//+------------------------------------------------------------------+

void PriceAction::func(){
}

void PriceAction::supportRessistance(){
   double tdiHandle  = NormalizeDouble(iCustom(_Symbol,PERIOD_CURRENT,"Ubot//ubot-rs.ex4",1,0),_Digits);
}

void PriceAction::trendLines(int inpStart = 10, int inpLength = 50){
   
   
   TrendHiLo *trend = new TrendHiLo(inpStart, inpLength);
   trend.update();
   
   PrintFormat("Upper at %i is %f", inpStart+inpLength, trend.upperValueAt(inpStart+inpLength));
   //PrintFormat("Lower at %i is %f", inpStart+inpLength, trend.lowerValueAt(inpStart+inpLength));
   
   ObjectDelete(0, "UpperTrend");
   ObjectDelete(0, "LowerTrend");
   
   ObjectCreate(0, "UpperTrend", OBJ_TREND, 0,
                  iTime(Symbol(), Period(), inpStart+inpLength), 
                  trend.upperValueAt(inpStart+inpLength),
                  iTime(Symbol(), Period(), 0), trend.upperValueAt(0));
                  
   ObjectSetInteger(0, "UpperTrend", OBJPROP_COLOR, clrSkyBlue);
   ObjectSetInteger(0, "UpperTrend", OBJPROP_WIDTH, 5);
   
   
   ObjectCreate(0, "LowerTrend", OBJ_TREND, 0,
                  iTime(Symbol(), Period(), inpStart+inpLength), 
                  trend.lowerValueAt(inpStart+inpLength),
                  iTime(Symbol(), Period(), 0), trend.lowerValueAt(0));
                  
   ObjectSetInteger(0, "LowerTrend", OBJPROP_COLOR, clrOrange);
   ObjectSetInteger(0, "LowerTrend", OBJPROP_WIDTH, 5);
   
   delete trend;
}




