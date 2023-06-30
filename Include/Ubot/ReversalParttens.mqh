//+------------------------------------------------------------------+
//|                                             ReversalParttens.mqh |
//|                                          Copyright 2022, Intela. |
//|                                             https://www.ubot.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Intela."
#property link      "https://www.ubot.com"
#property version   "1.00"

class ReversalParttens{
private:
     double candleHigh;
     double candleLow;
     double candleOpen;
     double candleClose;
     datetime candleTime;
   
     double pointCHigh;
     double pointAHigh;
     double pointCLow;
     double pointALow;
     datetime pointCTime;
     datetime pointATime;
     
     double pointAValue;
     double pointBValue;
     double pointCValue;
     double pointDValue;
     
     double pointA;
     double pointB;
     double pointC;
     double pointD;
     
     //Double bottom variables
     double pointAValueB;
     double pointBValueB;
     double pointCValueB;
     double pointDValueB;
     
     double pointAB[];
     double pointBB[];
     double pointCB[];
     double pointDB[];
     
     double pointCHighB;
     double pointAHighB;
     double pointCLowB;
     double pointALowB;
     datetime pointCTimeB;
     datetime pointATimeB;
     
     int zigzagHandle;
     string zigzag;
     bool alert;
     bool alertB;
     double bid;
     
     void initVariables();
     bool createObj(datetime dateTime, double price, int arrowCode, int direction,color clr, string name);
     
public:
          ReversalParttens();
         ~ReversalParttens();
     bool doubleBottom(); 
     bool doubleTop(); 
};

//Constructors
//+------------------------------------------------------------------+
ReversalParttens::ReversalParttens(){
   TesterHideIndicators(true);
   ReversalParttens::zigzag = "Ubot\\ubot-dt.ex4";
   //ReversalParttens::zigzagHandle = iCustom(_Symbol,PERIOD_CURRENT,ReversalParttens::zigzag);
   
}

ReversalParttens::~ReversalParttens(){}
//+------------------------------------------------------------------+
//double bottoms
//+------------------------------------------------------------------+
bool ReversalParttens::doubleBottom(){
   bool isFound = false;
   // 1 = buy; 0 = sell
   double doubleBottomTop = iCustom(_Symbol,PERIOD_CURRENT,ReversalParttens::zigzag,1,2);
   
   if(doubleBottomTop == 0){
      isFound = true;
   }

   
   return isFound;
}
//+------------------------------------------------------------------+
//double Tops
//+------------------------------------------------------------------+
bool ReversalParttens::doubleTop(){
   bool isFound = false;
   // 1 = buy; 0 = sell
   double doubleBottomTop = iCustom(_Symbol,PERIOD_CURRENT,ReversalParttens::zigzag,1,2);
   
   if(doubleBottomTop == 1){
      isFound = true;
   }
   
   return isFound;
}
//+------------------------------------------------------------------+