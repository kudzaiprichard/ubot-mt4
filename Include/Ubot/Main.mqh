//+------------------------------------------------------------------+
//|                                                         Main.mqh |
//|                                      Copyright 2022, U Bot Corp. |
//|                                             https://www.ubot.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, U Bot Corp."
#property link      "https://www.ubot.com"
#property version   "1.00"
#property strict

//Includes
#include <Ubot/CandleParttens.mqh>
#include <Ubot/OrderManager.mqh>
#include <Ubot/PriceAction.mqh>
#include <Ubot/ReversalParttens.mqh>
#include <Ubot/RiskManager.mqh>

class Main {

private:
   CandleParttens candleParttens;
   PriceAction priceAction;
   OrderManager orderManager;
   //TDI tdi;
   ReversalParttens reversalParttens;
   RiskManager riskManager;
   
   void trailProfit(double stopLoss, double takeProfit, int trailPrice);
   void peakFormationTrade();
   
public:
   Main();
   ~Main();
   void run();
   void TDITrades(bool lowSharkfin, bool highSharkfin, bool lowSqueeze, bool highSqueeze);
};
//+------------------------------------------------------------------+
//|Constructor                                                       |
//+------------------------------------------------------------------+
Main::Main(){}
Main::~Main(){}
//+------------------------------------------------------------------+

void Main::run(){

 
 // priceAction.trendLines(10, 50);
     // priceAction.supportRessistance();
     // priceAction.drawLowAndHighOfDay();
      //candleParttens.bearishStopHunt(1,PERIOD_CURRENT);
      //candleParttens.bullishStopHunt(1, PERIOD_CURRENT);
      candleParttens.stopHunt(1, PERIOD_CURRENT);
  
   /*
     TYPES OF TRADES DONE BY THE BOT
     +TDI TRADES
      -Low and high sharkfin
      -low and high squeeze
     
     +STOPHUNT/ PEAK FORMATION, LOD, HOD AND CANDLE PARTTENS
      -w formation
      -m formation
      -v formation
      -A formation
      
     +PRICE ACTION TRADES
      -break outs
   */
 
  
  
  
  //Todo: function needs more adjustments
  //Main::riskManager.trailProfit(5000, 500, 200);//stoploss , takeprofit , trailprice
   
}


//+TDI TRADES
//Function is used externally
//+-------------------------------------------------------------------------------------------+
void Main::TDITrades(bool lowSharkfin, bool highSharkfin, bool lowSqueeze, bool highSqueeze){

   if(highSharkfin == true){
      Print("highSharkfin");
      orderManager.openOrder(0.5,"sell","sharkfin high","market",3,0,250,500);//sl , tp
   }
   
   if(highSqueeze == true){
      Print("highSqueeze");
      orderManager.openOrder(0.5,"sell","sharkfin high","market",3,0,250,500);//sl , tp
   }
   
   if(lowSharkfin == true){
      Print("lowSharkfin");
      orderManager.openOrder(0.5,"buy","sharkfin low","market",3,0,250,500);//sl , tp
   }
   
   if(lowSqueeze == true){
      Print("lowSqueeze");
      orderManager.openOrder(0.5,"buy","sharkfin low","market",3,0,250,500);//sl , tp
   }
   
}
//+--------------------------------------------------------------------------------------------+


