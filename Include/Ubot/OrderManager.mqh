//+------------------------------------------------------------------+
//|                                                 OrderManager.mqh |
//|                                      Copyright 2022, U Bot Corp. |
//|                                             https://www.ubot.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, U Bot Corp."
#property link      "https://www.ubot.com"
#property version   "1.00"
#property strict
class OrderManager{
private:
   double pipSize();
   double pipSize(string symbol);
   double pipsToDouble( double pips);
   double pipsToDouble( double pips, string symbol);
   
   double priceBuy; 
   double stopLossBuy;
   double takeProfitBuy;
   
   double priceSell; 
   double stopLossSell;
   double takeProfitSell;
   
   double bid;
   double ask;
   
   int sellTicket;
   int buyTicket;
public:
   OrderManager();
   ~OrderManager();
   bool openOrder(double lotSize, string signal, string comment, string type, int positions, double price, double stopLoss, double takeProfit);
   bool trailProfits(int magicNumber, int trailingStop);
   bool isPositionInMinimumProfit(string symbol, int magic, ENUM_ORDER_TYPE type, double minProfit);
   bool newBar(string symbol = NULL, int timeframe = 0, bool initToNow = false);
   bool cutOnMinimumLoss(string symbol, int magic, ENUM_ORDER_TYPE type, double riskPercentage);
};

//+------------------------------------------------------------------+
//|CONSTRUCTOR                                                       |
//+------------------------------------------------------------------+
//Class Constructor functions
//+------------------------------------------------------------------+
OrderManager::OrderManager(){
   //OrderManager::openOrderMA = iMA(_Symbol, PERIOD_M15, 13, 0, MODE_EMA, PRICE_CLOSE);  
}

OrderManager::~OrderManager(){}
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|MAIN ORDER MANAGER FUNCTION                                       |
//+------------------------------------------------------------------+
//we can use this to open trades 
//as well as check if we are stil buying or selling like trend check
//+------------------------------------------------------------------+
bool OrderManager::openOrder(double lotSize, string signal, string comment, string type, int positions, double price, double stopLoss, double takeProfit){
   bool orderOpened = false;
   
   OrderManager::bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
   OrderManager::ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   
   price = price*10;
   stopLoss = stopLoss*10;
   takeProfit = takeProfit*10;
       
   for(int i = positions; i > 0; i--){  
         if(signal == "buy"){
            OrderManager::priceBuy = NormalizeDouble(OrderManager::ask+(price*_Point),_Digits); 
            
            if(stopLoss == 0) OrderManager::stopLossBuy = NULL;
            else OrderManager::stopLossBuy = NormalizeDouble(OrderManager::ask-(stopLoss*_Point),_Digits);
            
            if(takeProfit == 0) OrderManager::takeProfitBuy = NULL;
            else OrderManager::takeProfitBuy = NormalizeDouble(OrderManager::ask+(takeProfit*_Point),_Digits);
            
            if(type == "stop"){       
               OrderManager::buyTicket = OrderSend(_Symbol,OP_BUYSTOP,lotSize,OrderManager::priceBuy,3,
                                             OrderManager::stopLossBuy,OrderManager::takeProfitBuy,
                                             comment,0,0,clrGreen);                                               
            }else if(type == "market"){                    
               OrderManager::buyTicket = OrderSend(_Symbol,OP_BUY,lotSize,OrderManager::ask,3,
                                                   OrderManager::stopLossBuy,OrderManager::takeProfitBuy,
                                                   comment,0,0,clrGreen);
            }
         }
         
         if(signal == "sell"){
            OrderManager::priceSell = NormalizeDouble(OrderManager::bid-(price*_Point),_Digits); 
            
            if(stopLoss == 0) OrderManager::stopLossSell =NULL;
            else OrderManager::stopLossSell = NormalizeDouble(OrderManager::bid+(stopLoss*_Point),_Digits);
            
            if(takeProfit == 0) OrderManager::takeProfitSell = NULL;
            else OrderManager::takeProfitSell = NormalizeDouble(OrderManager::bid-(takeProfit*_Point),_Digits);
            
            if(type == "stop"){           
               OrderManager::sellTicket = OrderSend(_Symbol,OP_SELLSTOP,lotSize,OrderManager::priceSell,3,
                                             OrderManager::stopLossSell,OrderManager::takeProfitSell,
                                             comment,0,0,clrRed); 
            }else if(type == "market"){                                     
              OrderManager::sellTicket  = OrderSend(_Symbol,OP_SELL,lotSize,OrderManager::bid,3,
                                               OrderManager::stopLossSell,OrderManager::takeProfitSell,
                                               comment,0,0,clrRed);
            }
         }
      }
      
      if(OrderManager::sellTicket > 0 || OrderManager::buyTicket > 0){orderOpened = true;}

   return orderOpened;   
}                                                                  
//+------------------------------------------------------------------+

double OrderManager::pipSize(){return(pipSize(Symbol()));}

double OrderManager::pipSize(string symbol){
   double   point    =  SymbolInfoDouble(symbol,SYMBOL_POINT);
   int      digits   =  (int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
   return((digits % 2) == 1) ? point * 10 : point; 
}

double OrderManager::pipsToDouble( double pips){return(pips*pipSize(Symbol()));}
double OrderManager::pipsToDouble( double pips, string symbol){return(pips*pipSize(symbol));}

//Trail profit function, which also handles breakeven
//+------------------------------------------------------------------+
bool OrderManager::trailProfits(int magicNumber, int trailingStop){
   double   buyTrailingStopPrice    =  Ask-trailingStop;
   double   sellTrailingStopPrice   =  Bid+trailingStop; 
   int      err;
   bool trail = false;
   
   for(int  i  =  OrdersTotal()-1;  i>=0; i--){
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderSymbol() != Symbol() || OrderMagicNumber() != magicNumber) continue;
      
      if(OrderType()==ORDER_TYPE_BUY && buyTrailingStopPrice>OrderOpenPrice() 
      && (OrderStopLoss()==0 || buyTrailingStopPrice>OrderStopLoss())){
         ResetLastError();
         if(!OrderModify(OrderTicket(), OrderOpenPrice() , buyTrailingStopPrice, OrderTakeProfit(), OrderExpiration())){
            err = GetLastError();
            PrintFormat("Failed to update ts on ticket %i to %f, err=%i", OrderTicket(), buyTrailingStopPrice, err);
         }else return(true);

      }
      
      if(OrderType() == ORDER_TYPE_SELL && sellTrailingStopPrice<OrderOpenPrice() 
      && (OrderStopLoss() ==0 || sellTrailingStopPrice<OrderStopLoss())){
         ResetLastError();
         if(!OrderModify(OrderTicket(), OrderOpenPrice(), sellTrailingStopPrice, OrderTakeProfit(),OrderExpiration())){
            err = GetLastError();
            PrintFormat("Failed to update ts on ticket %i to %f, err=%i", OrderTicket(), sellTrailingStopPrice, err);
         }else return(true);
      
      }
   }
   return(false);
}
//+------------------------------------------------------------------+


//+------------------------------------------------------------------------------------+
bool OrderManager::newBar(string symbol = NULL, int timeframe = 0, bool initToNow = false){
   datetime          currentBarTime    =  iTime(symbol, (ENUM_TIMEFRAMES)timeframe, 0);
   static datetime   previousBarTime   =  initToNow ? currentBarTime : 0;
   if(previousBarTime == currentBarTime) return (false);
   previousBarTime = currentBarTime;
   return (true);   
}
//+---------------------------------------------------------------------------------------+


//+---------------------------------------------------------------------------------------+
bool OrderManager::isPositionInMinimumProfit(string symbol, int magic, ENUM_ORDER_TYPE type, double minProfit){

   for(int i = OrdersTotal()-1; i >= 0; i--){
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) return (false);
      
      if(OrderSymbol() == symbol && OrderMagicNumber() == magic && OrderType() == type){
         if(OrderProfit() > minProfit) return (true);
      }
   }
   return (false);
}
//+---------------------------------------------------------------------------------------+


//Total profit calculation
//+---------------------------------------------------------------------------------------+
bool OrderManager::cutOnMinimumLoss(string symbol, int magic, ENUM_ORDER_TYPE type, double riskPercentage){
   double totalLoss = 0;
   
   for(int i = OrdersTotal()-1; i >= 0; i--){
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) return (false);
      
      if(OrderSymbol() == symbol && OrderMagicNumber() == magic && OrderType() == type){
         if(-(riskPercentage*AccountBalance())  >= OrderProfit()) return(true);
      }
   }
   
   return (false);
}
//+---------------------------------------------------------------------------------------+