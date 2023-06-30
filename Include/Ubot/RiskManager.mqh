//+------------------------------------------------------------------+
//|                                                  RiskManager.mqh |
//|                                      Copyright 2022, U Bot Corp. |
//|                                             https://www.ubot.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, U Bot Corp."
#property link      "https://www.ubot.com"
#property version   "1.00"
#property strict
class RiskManager{
private:

public:
   RiskManager();
   ~RiskManager();
   void trailProfit(double stopLoss, double takeProfit, int trailPrice);
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
RiskManager::RiskManager(){}
RiskManager::~RiskManager(){}
//+------------------------------------------------------------------+

//Trails the profit by Modifying the open position sl
//+------------------------------------------------------------------+
void RiskManager::trailProfit(double stopLoss, double takeProfit, int trailPrice){
trailPrice = trailPrice*10;
takeProfit = takeProfit*10;
stopLoss = stopLoss*10;
   for(int b = OrdersTotal()-1; b >= 0; b--){
      if(OrderSelect(b, SELECT_BY_POS,MODE_TRADES)){
         if(OrderSymbol() == Symbol()){
         
            if(OrderType() == OP_BUY){
               if(OrderStopLoss() < Ask - (trailPrice * _Point)){
                  int ticket = OrderModify(
                     OrderTicket(),          //for current order
                     OrderOpenPrice(),       //opened for the openprice
                     Ask - (stopLoss * _Point),   //set stop loss
                     Ask + (takeProfit * _Point),   //set take profit
                     0,                      //no expiration date
                     clrLime               //no color
                  );
               }
            }
            
            
            if(OrderType() == OP_SELL){
               if(OrderStopLoss() > Ask + (trailPrice * _Point)){
                  int ticket = OrderModify(
                     OrderTicket(),          //for current order
                     OrderOpenPrice(),       //opened for the openprice
                     Bid + (stopLoss * _Point),   //set stop loss
                     Bid - (takeProfit * _Point),   //set take profit
                     0,                      //no expiration date
                     clrOrange                //no color
                  );
               }
            }
            
         }
      }
   }
}
//+------------------------------------------------------------------+