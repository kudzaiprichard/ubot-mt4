//+------------------------------------------------------------------+
//|                                                         Ubot.mq4 |
//|                                      Copyright 2022, U Bot Corp. |
//|                                             https://www.ubot.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, U Bot Corp."
#property link      "https://www.ubot.com"
#property version   "1.00"
#property strict

//INCLUDES
#include <Ubot/TDI.mqh>
#include <Ubot/OrderManager.mqh>
#include <Ubot/Chart.mqh>
#include <Ubot/Dashboard.mqh>
#include <Ubot/Trend.mqh>
//USER INPUTS
//ORDER INPUTS
input int      InpTakeProfit        =  0;
input int      InpStopLoss          =  900;
input double   InpLotSize           =  0.01;
input int      InpPositions         =  1;
input int      InpTrailProfit       =  170;
input int      InpSharkfinStopLoss  =  900;

//INPUTS ON SCALING
//input double   InpScaleLotSize            =  0.5;
input double      InpScaleOnProfit           =  0.5;
input int         InpFirstScalePositions     =  2;
input int         InpSecondScalePositions    =  1;
input int         InpThirdScalePositions     =  1;

input int         InpScaleTakeProfit         =  2000; 
input int         InpFirstScaleStopLoss      =  500;
input int         InpSecondScaleStopLoss     =  500;
input int         InpThirdScaleStopLoss      =  500;
//input double      InpRiskPercentage        =  0.2;

input bool        InpAllowBreakEven          =  true;

//STRATEGY SETTINGS
//SQUEEZE INPUTS 
int InpBounceTolerance     =  2;
int InpLevelOfCompresion   =  11;

//INPUTS FOR SQUEZZE SHARKFIN
int      InpSharkfinSize                     =  2;
int      InpSharkfinSqueezeCompresion        =  11;

//TRADE TYPE INPUTS, FOR ME
//input bool InpSharkfin = false;
//input bool InpSqueeze  = false;

//VARIABLES
bool breakT             =     true;
bool isOpen             =     false;
bool traile             =     false;
bool squeez             =     false;
bool shark              =     false;
//bool op                 =     true;
bool secondScale        =     false;
bool thirdScale         =     false;
bool stop = false;

TDI            tdi(InpLotSize,InpTakeProfit,InpStopLoss,InpSharkfinStopLoss,InpPositions);
OrderManager   order;
Chart          chart;
Dashboard      *dashboard;
Trend          trend;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   chart.SetChartProperties();
   dashboard   = new Dashboard("test", 15);
   dashboard.addRow("",clrBlack, "Tahoma", 11);
   dashboard.addRow("",clrBlack, "Tahoma", 11);
   dashboard.addRow("",clrBlack, "Tahoma", 11);
   dashboard.addRow("",clrBlack, "Tahoma", 11);
   dashboard.addRow("",clrBlack, "Tahoma", 11);
   dashboard.addRow("",clrBlack, "Tahoma", 11);
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   delete dashboard;
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){
   tdi.initialize();
   tdi.manage();
   tdi.expire();
   //cloTrades();
   displayDashboard();
   datetime currentCandleTime =  iTime(_Symbol,PERIOD_M15,0);
   int hour = TimeHour(currentCandleTime); 
   
   trade(hour, "squeeze");

    if(stop == false && OrdersTotal() > 1){
      breakEven(ORDER_TYPE_BUY);
      breakEven(ORDER_TYPE_SELL);
    } 
     if(OrdersTotal() > 0){
         for(int  i  =  OrdersTotal()-1;  i>=0; i--){
            if(OrderType()==ORDER_TYPE_BUY){
               if(OrderStopLoss() > OrderOpenPrice()){
                  stop = true;  
               }
            }
            
            if(OrderType() == ORDER_TYPE_SELL){
               if(OrderStopLoss() <  OrderOpenPrice()){
                   stop = true; 
               }
            }
         }
      }
   
}
//+------------------------------------------------------------------+
void trade(int hour, string type){
    
   if(type == "squeeze" && squeez == false){
      if(tdi.middleSqueeze(InpLevelOfCompresion,InpBounceTolerance)){
         squeez = true;
      } 
   }
   
   if(type == "squeeze sharkfin"){
      tdi.squeezeSharkfin(InpSharkfinSqueezeCompresion,InpSharkfinSize);
   }
   
   if(type == "low sharkfin"){    
      if(tdi.lowSharkfin())shark = true;
   }
   
   if(type == "high sharkfin"){
     if(tdi.highSharkfin())shark = true;
   }
   
   if(OrdersTotal() <= InpFirstScalePositions){ //TODO: should fix if order is one
      //first scale
      if(isOpen == false && shark == true){
         if(type == "high sharkfin" || type == "low sharkfin") 
            isOpen = scaleIn(hour,InpFirstScaleStopLoss,InpScaleTakeProfit,type,1);
      }
      
      if(isOpen == false && squeez == true){
         if(type == "squeeze") 
            isOpen = scaleIn(hour,InpFirstScaleStopLoss,InpScaleTakeProfit,type,1); 
      }
   }
   
   
   if(hour == 0){
      isOpen         =  false;
      traile         =  false;
      squeez         =  false;
      shark          =  false;
      secondScale    =  false;
      thirdScale     =  false;
   }
   
   if(OrdersTotal() == 0){ stop = false;}
   
   //if(hour == 23) closePositions();
   
}

bool scaleIn(int hour, int stopLoss, int takeProfit, string type, int scaleIndex){
   bool scale = false;
   if(hour != 0){
      //FIRST SCALE
      if(OrdersTotal() == 1){
         if(type == "squeeze sharkfin" || type == "squeeze"){
            if(scaleInByType(ORDER_TYPE_BUY,stopLoss, takeProfit,InpScaleOnProfit, scaleIndex, InpFirstScalePositions))   scale = true;
            if(scaleInByType(ORDER_TYPE_SELL,stopLoss, takeProfit,InpScaleOnProfit, scaleIndex, InpFirstScalePositions))  scale = true; 
         }
         
         if(type == "low sharkfin" || type == "high sharkfin"){
            if(scaleInByType(ORDER_TYPE_BUY,stopLoss, takeProfit,0.1, scaleIndex, InpFirstScalePositions))   scale = true;
            if(scaleInByType(ORDER_TYPE_SELL,stopLoss, takeProfit,0.1, scaleIndex, InpFirstScalePositions))  scale = true; 
         }
      }
      
   }
   return scale; 
}


bool scaleInByType(ENUM_ORDER_TYPE type, int stopLoss, int takeProfit, double scaleOn, int scaleIndex, int positions){
   bool scale = false;
   string name = "first scale";
   if(type == ORDER_TYPE_BUY){
      if(trend.emaTrend(PERIOD_M15) && trend.emaTrend(PERIOD_H1)){
         if(order.isPositionInMinimumProfit(Symbol(),NULL,type,scaleOn)){
            if(scaleIndex == 1) traile = closePositions();
            if(scaleIndex == 2) name = "second scale";
            if(scaleIndex == 3) name = "third scale";
            order.openOrder(calaculateLotSize(),"buy","Buy Scale","market",positions,0,stopLoss,takeProfit);
            scale = true;  
         }
      }
   }
   
   if(type == ORDER_TYPE_SELL){ 
      if(!trend.emaTrend(PERIOD_M15) && !trend.emaTrend(PERIOD_H1)){
         if(order.isPositionInMinimumProfit(Symbol(),NULL,type,scaleOn)){
            if(scaleIndex == 1) traile = closePositions();
            if(scaleIndex == 2) name = "second scale";
            if(scaleIndex == 3) name = "third scale";
            order.openOrder(calaculateLotSize(),"sell","Sell Scale","market",positions,0,stopLoss,takeProfit);
            scale = true;  
         }
      }
   }
   return scale;
}

///*
//WORK ON BREAK EVEN OR WHAT TO DO WHEN YOU SCALE AND THE MARKET GOES THE OTHER DIRECTION
bool closePositions(){
   bool closed = false;
   for(int  i  =  OrdersTotal()-1;  i>=0; i--){
      if(OrderType()==ORDER_TYPE_BUY){
         closed = OrderClose(OrderTicket(),OrderLots(), Bid, NULL, clrBlack);
      }
      
      if(OrderType() == ORDER_TYPE_SELL){
         closed = OrderClose(OrderTicket(), OrderLots(), Ask, NULL, clrBlack);
      }
   }
   return closed;
}


void breakEven(ENUM_ORDER_TYPE type,int breakPoint = 50){
   if(order.trailProfits(NULL,breakPoint)){
      if(OrdersTotal() > 0){
         
         for(int  i  =  OrdersTotal()-1;  i>=0; i--){
            if(OrderType()==ORDER_TYPE_BUY){
               if(OrderStopLoss() > OrderOpenPrice()){
                 traile = true; 
               }
            }
            
            if(OrderType() == ORDER_TYPE_SELL){
               if(OrderStopLoss() <  OrderOpenPrice()){
                  traile = true;
               }
            }
         }
      }
      
   }

}


void displayDashboard(){
   //static datetime currentTime;
   double   currentSpread  =  (Ask-Bid);
  
   //dashboard.setYDistance(200);
   
   dashboard.setRow(0,StringFormat("Symbol: %s", Symbol()), clrChocolate, "Courier", 14);
   
   if(currentSpread > 3.4){
      dashboard.setRow(1, StringFormat("Spread: %.2f", currentSpread), clrLimeGreen, "Courier", 11); 
   }
   else{
      dashboard.setRow(1, StringFormat("Spread: %.2f", currentSpread), clrOrange, "Courier", 11);
   }
   
   dashboard.setRowText(2, StringFormat("Ask: %.1f", Ask));
   dashboard.setRowText(3, StringFormat("Bid: %.1f", Bid));
   dashboard.setRow(4,"UBOT v1", clrLimeGreen, "Courier", 14);
   
   
   if(Close[0]>Open[0]){
      dashboard.setRow(5, CharToStr(233), clrBlue, "Wingdings",15);
   }
   else if(Close[0]<Open[0]){
      dashboard.setRow(5, CharToStr(234), clrRed, "Wingdings",15);
   }
   else{
      dashboard.setRow(5, CharToStr(232), clrBlack, "Wingdings",15);
   }
   
}


//Calculates the a safe lotsize to use according to your acc size
double calaculateLotSize(){
   return( NormalizeDouble( (floor(AccountBalance()* 1) * 0.1) / 100, 1 ) );
}


//Calculates the right amount to scale at
double scaleOnProfit(){
   return( NormalizeDouble((20*calaculateLotSize()/0.5),1) );
}

//Prevents account form blowing up
//Makes sure Loss doesnt go above 40% of the account
void  cutOnMinimumLoss(double riskPercentage = 0.2){
   if(
      order.cutOnMinimumLoss(Symbol(),NULL,ORDER_TYPE_BUY, riskPercentage) 
      || order.cutOnMinimumLoss(Symbol(),NULL,ORDER_TYPE_SELL, riskPercentage)
   ){
      closePositions();
   }
}

void cloTrades(){
   if(OrdersTotal()>0){
      for(int  i  =  OrdersTotal()-1;  i>=0; i--){
         if(OrderType()==ORDER_TYPE_BUY){
            if(!trend.ubotTrend(PERIOD_M15)) closePositions();
         }
         if(OrderType() == ORDER_TYPE_SELL){
            if(trend.ubotTrend(PERIOD_M15)) closePositions();
         }
      }
   }
}