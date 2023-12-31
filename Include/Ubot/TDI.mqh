//+------------------------------------------------------------------+
//|                                                          TDI.mqh |
//|                                      Copyright 2022, U Bot Corp. |
//|                                             https://www.ubot.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, U Bot Corp."
#property link      "https://www.ubot.com"
#property version   "1.00"
#property strict

#include<Ubot/OrderManager.mqh>
#include<Ubot/Trend.mqh>

struct DateAndTime{
   int hours;
   int minutes;
   int seconds;
};

//Signal
struct Signal{
   int         type; //buy: 0, sell: 1
   DateAndTime time;
   int         accuracy;//determined by how much that signal type appeared on the chart
   int         status; //expired: 0, executed: 1, 2: pending
};

class TDI{
private:
   OrderManager   orderManager;
   DateAndTime    currentDateTime;
   Trend          trend;
   string tdi;
   double tdiHandleRed;
   double tdiHandleYellow;
   double tdiHandleGreen;
   
   double tdiHandleUpperBlue;
   double tdiHandleLowerBlue;
   
   double emaHandle;
   string ema;
   
   int extremHighLevel;
   int highLevel;
   int middleLevel;
   int lowerLevel;
   int extremLowerLevel;
   
   bool lowSharkfinConfimation[10];
   bool highSharkfinConfimation[10];
 
   bool lowSqueezeConfimation[3];
   bool highSqueezeConfimation[3];
   
   bool middleSqueezeConfimation[15];
   bool squeezeSharkfinConfimation[10];
   
   int      TakeProfit;
   int      StopLoss;
   int      SharkfinStoploss;
   int      Positons;  
   double   LotSize;
   
   double   candleHigh;
   double   candleLow;
   double   candleOpen;
   double   candleClose;
   
   Signal   signalArray[];
public:
   TDI(double lotSize, int takeProfit, int stopLoss, int sharkfinStoploss,int positions);
   ~TDI();
   bool lowSharkfin();
   bool highSharkfin();
   bool highSqueeze(int levelOfCompresionX, int bounceToleranceX);
   bool lowSqueeze(int levelOfCompresionX , int bounceToleranceX);
   bool middleSqueeze(int levelOfCompresionX, int bounceToleranceX);
   void squeezeSharkfin(int levelOfCompresion, int sharkfinSize);
   void initialize();
   void manage();
   void expire();
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TDI::TDI(double lotSize, int takeProfit, int stopLoss, int sharkfinStoploss,int positions){
   
   TDI::TakeProfit         =  takeProfit;
   TDI::StopLoss           =  stopLoss;
   TDI::Positons           =  positions;
   TDI::LotSize            =  lotSize; 
   TDI::SharkfinStoploss   =  sharkfinStoploss;
   
   TDI::tdi = "Ubot//ubot-tdi.ex4";
   TDI::extremHighLevel    = 68;
   TDI::highLevel          = 63;
   TDI::middleLevel        = 50;
   TDI::lowerLevel         = 37;
   TDI::extremLowerLevel   = 32;
   
   lowSharkfinConfimation[0]  = false;
   lowSharkfinConfimation[1]  = false;
   lowSharkfinConfimation[2]  = false;
   lowSharkfinConfimation[3]  = false;
   lowSharkfinConfimation[4]  = false;
   lowSharkfinConfimation[5]  = false;
   lowSharkfinConfimation[6]  = false;
   lowSharkfinConfimation[7]  = false;
   
   highSharkfinConfimation[0] = false;
   highSharkfinConfimation[1] = false;
   highSharkfinConfimation[2] = false;
   highSharkfinConfimation[3] = false;
   highSharkfinConfimation[4] = false;
   highSharkfinConfimation[5] = false;
   highSharkfinConfimation[6] = false;
   
   lowSqueezeConfimation[0]   = false;
   lowSqueezeConfimation[1]   = false;
   lowSqueezeConfimation[2]   = false;
   
   highSqueezeConfimation[0]  = false;
   highSqueezeConfimation[1]  = false;
   highSqueezeConfimation[2]  = false;
   
   middleSqueezeConfimation[1]  =  false;
   middleSqueezeConfimation[2]  =  false;
   middleSqueezeConfimation[3]  =  false;
   middleSqueezeConfimation[4]  =  true;
   middleSqueezeConfimation[5]  =  true;
   middleSqueezeConfimation[8]  =  false;
   middleSqueezeConfimation[9]  =  false;
   middleSqueezeConfimation[10]  =  false;
   middleSqueezeConfimation[11]  =  false;
   
   squeezeSharkfinConfimation[0] =  false;
   squeezeSharkfinConfimation[1] =  false;
   squeezeSharkfinConfimation[2] =  false;
   squeezeSharkfinConfimation[3] =  false;
   squeezeSharkfinConfimation[4] =  true;

}
TDI::~TDI(){}
//+------------------------------------------------------------------+

void TDI::initialize(){
   datetime currentCandleTime =  iTime(_Symbol,PERIOD_M15,0);
   TDI::tdiHandleYellow       =  NormalizeDouble(iCustom(_Symbol,PERIOD_M15,TDI::tdi,21,0,34,2,0,7,0,false,63,37,false,false,45,55,false,false,0.0001,2,0),_Digits);
   TDI::tdiHandleGreen        =  NormalizeDouble(iCustom(_Symbol,PERIOD_M15,TDI::tdi,21,0,34,2,0,7,0,false,63,37,false,false,45,55,false,false,0.0001,4,0),_Digits);
   TDI::tdiHandleRed          =  NormalizeDouble(iCustom(_Symbol,PERIOD_M15,TDI::tdi,21,0,34,2,0,7,0,false,63,37,false,false,45,55,false,false,0.0001,5,0),_Digits);
   
   TDI::tdiHandleUpperBlue    =  NormalizeDouble(iCustom(_Symbol,PERIOD_M15,TDI::tdi,21,0,34,2,0,7,0,false,63,37,false,false,45,55,false,false,0.0001,1,0),_Digits);
   TDI::tdiHandleLowerBlue    =  NormalizeDouble(iCustom(_Symbol,PERIOD_M15,TDI::tdi,21,0,34,2,0,7,0,false,63,37,false,false,45,55,false,false,0.0001,3,0),_Digits);
   TDI::emaHandle             =  NormalizeDouble(iMA(_Symbol,PERIOD_M15,13,0,MODE_EMA,PRICE_CLOSE,0),_Digits);
   
   TDI::candleHigh            =  iHigh(_Symbol,PERIOD_M15,1);
   TDI::candleLow             =  iLow(_Symbol,PERIOD_M15,1);
   TDI::candleClose           =  iClose(_Symbol,PERIOD_M15,1);
   TDI::candleOpen            =  iOpen(_Symbol,PERIOD_M15,1);
   
   currentDateTime.hours      =  TimeHour(currentCandleTime);
   currentDateTime.minutes    =  TimeMinute(currentCandleTime);
   currentDateTime.seconds    =  TimeSeconds(currentCandleTime);
}

//TDI low sharkfin (buy)
//+------------------------------------------------------------------+
bool TDI::lowSharkfin(){
   bool  sharkfin    =  false;
   int   accuray     =  1;
   Signal signal;
   
   if(ArraySize(signalArray) == 0){
      signal.type          =  0;
      signal.time.hours    =  currentDateTime.hours;
      signal.time.minutes  =  currentDateTime.minutes;
      signal.time.seconds  =  currentDateTime.seconds;
      signal.accuracy      =  1;
      signal.status        =  2;
   }
  
   //index 0 : move beyond the 32 level and beyond the blue volatility
   if(lowSharkfinConfimation[0]     == false 
   && lowSharkfinConfimation[1]     == false
   && middleSqueezeConfimation[0]   == false
   ){
      if(TDI::tdiHandleGreen < TDI::lowerLevel
      && TDI::tdiHandleGreen < (TDI::tdiHandleLowerBlue - 1)
      ){
         lowSharkfinConfimation[0] = true;
       }
   } 
   
   //DETECTING THE FIRST LEG
   //index 1 : hook formation across the Blue Volatility band a “hook up" 
   if(lowSharkfinConfimation[0] == true 
   && lowSharkfinConfimation[1] == false
   ){
      //first leg of the W formation
      if(TDI::tdiHandleGreen > TDI::tdiHandleLowerBlue){
         lowSharkfinConfimation[1] = true;
      }
   }
   
   if(lowSharkfinConfimation[1] == true 
   && lowSharkfinConfimation[2] == false
   ){
      
      if(TDI::emaHandle < Bid){
         if(ArraySize(signalArray) == 0){
            signal.type          =  0;
            signal.time.hours    =  currentDateTime.hours;
            signal.time.minutes  =  currentDateTime.minutes;
            signal.time.seconds  =  currentDateTime.seconds;
            signal.accuracy      =  accuray;
            signal.status        =  2;
         }
         else{
            //Check the last signals to determine the next signal accuracy
            for(int index = 0; index < ArraySize(signalArray); index++){
               if(signalArray[index].status == 2
               && signalArray[(index)].type == 0
               )accuray++;
            }          
            
            signal.type          =  0;
            signal.time.hours    =  currentDateTime.hours;
            signal.time.minutes  =  currentDateTime.minutes;
            signal.time.seconds  =  currentDateTime.seconds;
            signal.accuracy      =  accuray;
            signal.status        =  2; 
         }
         
         if(ArrayResize(signalArray,1)) signalArray[(ArraySize(signalArray) - 1)] = signal;
         lowSharkfinConfimation[2] = true;
         sharkfin = true;
      }
   }
   
   //Reset the array
   if((lowSharkfinConfimation[0] == true 
   && lowSharkfinConfimation[1] == true
   && lowSharkfinConfimation[2] == true)
   || currentDateTime.hours == 0
   ){
      lowSharkfinConfimation[0] = false; 
      lowSharkfinConfimation[1] = false;
      lowSharkfinConfimation[2] = false;
   }
     
   return sharkfin;
}
//+------------------------------------------------------------------+

//TDI high sharkfin(sell)
//+------------------------------------------------------------------+
bool TDI::highSharkfin(){
   bool sharkfin     = false;
   int   accuray     =  1;
   Signal signal;
   
   //index 0 : move beyond the the 68 level and beyond the Blue Volatility
   if(highSharkfinConfimation[0]    == false 
   && highSharkfinConfimation[1]    == false
   && middleSqueezeConfimation[0]   == false
   ){
      if(TDI::tdiHandleGreen >  TDI::highLevel
      && TDI::tdiHandleGreen > (TDI::tdiHandleUpperBlue + 1)
      ){
         highSharkfinConfimation[0] = true;
       }
   }
   
   //index 1 : hook formation across the Blue Volatility band a "hook down"
   if(highSharkfinConfimation[0] == true 
   && highSharkfinConfimation[1] == false
   ){
      if(TDI::tdiHandleGreen < TDI::tdiHandleUpperBlue){
         highSharkfinConfimation[1] = true;
      }
   }
   
   if(highSharkfinConfimation[1] == true 
   && highSharkfinConfimation[2] == false
   ){
      
      if(TDI::emaHandle > Bid){
         if(ArraySize(signalArray) == 0){
            signal.type          =  1;
            signal.time.hours    =  currentDateTime.hours;
            signal.time.minutes  =  currentDateTime.minutes;
            signal.time.seconds  =  currentDateTime.seconds;
            signal.accuracy      =  accuray;
            signal.status        =  2;
         }
         else{
            //Check the last signals to determine the next signal accuracy
            for(int index = 0; index < ArraySize(signalArray); index++){
               if(signalArray[index].status == 2
               && signalArray[(index)].type == 1
               )accuray++;
            }          
            
            signal.type          =  1;
            signal.time.hours    =  currentDateTime.hours;
            signal.time.minutes  =  currentDateTime.minutes;
            signal.time.seconds  =  currentDateTime.seconds;
            signal.accuracy      =  accuray;
            signal.status        =  2; 
         }
         
         if(ArrayResize(signalArray,1)) signalArray[(ArraySize(signalArray) - 1)] = signal;
         highSharkfinConfimation[2] = true;
         sharkfin = true;
      }
   }
 
   //Reset the array
   if(
     (highSharkfinConfimation[0] == true 
   && highSharkfinConfimation[1] == true
   && highSharkfinConfimation[2] == true)
   || currentDateTime.hours == 0
   ){ 
      highSharkfinConfimation[0] = false; 
      highSharkfinConfimation[1] = false;
      highSharkfinConfimation[2] = false;
   }  
   
   return sharkfin;
}
//+------------------------------------------------------------------+



//TDI middle squeeze
//Uncomment the open positions
//+------------------------------------------------------------------+
bool TDI::middleSqueeze(int levelOfCompresionX, int bounceToleranceX){
   bool squeeze      = false;
   int   accuray     =  1;
   Signal signal;
   //---------------------------------------------------------------------------------------------------------
   //FOR BUY
   //Step one detect the condition
   //middleSqueezeConfimation[4] == for Buy
   if(middleSqueezeConfimation[0] == false && middleSqueezeConfimation[4] == true){
      if(
            (TDI::tdiHandleUpperBlue + 2) < TDI::middleLevel
         && TDI::tdiHandleUpperBlue - TDI::tdiHandleLowerBlue <= levelOfCompresionX // compressed
      ){ 
         // All the lines should be compressed inside the two blue lines
         if((TDI::tdiHandleLowerBlue < TDI::tdiHandleGreen && TDI::tdiHandleUpperBlue > TDI::tdiHandleGreen)
            && (TDI::tdiHandleLowerBlue < TDI::tdiHandleRed && TDI::tdiHandleUpperBlue > TDI::tdiHandleRed)
            && (TDI::tdiHandleLowerBlue < TDI::tdiHandleYellow && TDI::tdiHandleUpperBlue > TDI::tdiHandleYellow)
           ){  
               //Look for Green above Red and above yellow
               if(TDI::tdiHandleGreen > TDI::tdiHandleRed
               && TDI::tdiHandleGreen > TDI::tdiHandleYellow
               ){ 
                  middleSqueezeConfimation[0] = true;
                  middleSqueezeConfimation[5] = false; 
               }
           }
      }
   }
   
   //Step two detect a breakout
   if(middleSqueezeConfimation[0] == true 
   && middleSqueezeConfimation[1] == false 
   && middleSqueezeConfimation[4] == true
   ){
      if(TDI::tdiHandleGreen > (TDI::tdiHandleUpperBlue + bounceToleranceX)){
      if(TDI::emaHandle < Bid){
         
         if(ArraySize(signalArray) == 0){
            signal.type          =  0;
            signal.time.hours    =  currentDateTime.hours;
            signal.time.minutes  =  currentDateTime.minutes;
            signal.time.seconds  =  currentDateTime.seconds;
            signal.accuracy      =  accuray;
            signal.status        =  2;
         }
         else{
            //Check the last signals to determine the next signal accuracy
            for(int index = 0; index < ArraySize(signalArray); index++){
               if(signalArray[index].status == 2
               && signalArray[(index)].type == 0
               )accuray++;
            }          
            
            signal.type          =  0;
            signal.time.hours    =  currentDateTime.hours;
            signal.time.minutes  =  currentDateTime.minutes;
            signal.time.seconds  =  currentDateTime.seconds;
            signal.accuracy      =  accuray;
            signal.status        =  2; 
         }
         
         if(ArrayResize(signalArray,1)) signalArray[(ArraySize(signalArray) - 1)] = signal;
         middleSqueezeConfimation[1] = true;
         squeeze = true;
       }
       }
       
      if(TDI::tdiHandleGreen < (TDI::tdiHandleLowerBlue - 4)){
         middleSqueezeConfimation[1] = true;
         middleSqueezeConfimation[10] = true;
       }
   }
   
   if(middleSqueezeConfimation[10] == true && middleSqueezeConfimation[11] == false){
      if(TDI::tdiHandleGreen > TDI::tdiHandleLowerBlue){
         if(TDI::emaHandle < Bid){
         //orderManager.openOrder(TDI::LotSize,"buy","squezze shark low","market",TDI::Positons,0,TDI::StopLoss,TDI::TakeProfit);//sl , tp
         if(ArraySize(signalArray) == 0){
            signal.type          =  0;
            signal.time.hours    =  currentDateTime.hours;
            signal.time.minutes  =  currentDateTime.minutes;
            signal.time.seconds  =  currentDateTime.seconds;
            signal.accuracy      =  accuray;
            signal.status        =  2;
         }
         else{
            //Check the last signals to determine the next signal accuracy
            for(int index = 0; index < ArraySize(signalArray); index++){
               if(signalArray[index].status == 2
               && signalArray[(index)].type == 0
               )accuray++;
            }          
            
            signal.type          =  0;
            signal.time.hours    =  currentDateTime.hours;
            signal.time.minutes  =  currentDateTime.minutes;
            signal.time.seconds  =  currentDateTime.seconds;
            signal.accuracy      =  accuray;
            signal.status        =  2; 
         }
         
         if(ArrayResize(signalArray,1)) signalArray[(ArraySize(signalArray) - 1)] = signal;
         middleSqueezeConfimation[11] = true;
         squeeze = true;
      }
      }
   }
   

   //---------------------------------------------------------------------------------------------------------
   //FOR SELL
   //Step one detect the condition
   if(middleSqueezeConfimation[0] == false && middleSqueezeConfimation[5] == true){
      if(
            (TDI::tdiHandleLowerBlue - 2) > TDI::middleLevel
         && TDI::tdiHandleUpperBlue - TDI::tdiHandleLowerBlue <= levelOfCompresionX // compressed
      ){ 
         // All the lines should be compressed inside the two blue lines
         if((TDI::tdiHandleLowerBlue < TDI::tdiHandleGreen && TDI::tdiHandleUpperBlue > TDI::tdiHandleGreen)
            && (TDI::tdiHandleLowerBlue < TDI::tdiHandleRed && TDI::tdiHandleUpperBlue > TDI::tdiHandleRed)
            && (TDI::tdiHandleLowerBlue < TDI::tdiHandleYellow && TDI::tdiHandleUpperBlue > TDI::tdiHandleYellow)
           ){  
               //Look for Green below Red and below yellow
               if(TDI::tdiHandleGreen < TDI::tdiHandleRed
               && TDI::tdiHandleGreen < TDI::tdiHandleYellow
               ){
                  middleSqueezeConfimation[0] = true;
                  middleSqueezeConfimation[4] = false;
               }
           }
      }
   }
   
   
   //Step two detect a breakout
   if(middleSqueezeConfimation[0] == true 
   && middleSqueezeConfimation[1] == false
   && middleSqueezeConfimation[5] == true
   ){
      if(TDI::tdiHandleGreen < (TDI::tdiHandleLowerBlue - bounceToleranceX)){
      if(TDI::emaHandle > Bid){
         if(ArraySize(signalArray) == 0){
            signal.type          =  1;
            signal.time.hours    =  currentDateTime.hours;
            signal.time.minutes  =  currentDateTime.minutes;
            signal.time.seconds  =  currentDateTime.seconds;
            signal.accuracy      =  accuray;
            signal.status        =  2;
         }
         else{
            //Check the last signals to determine the next signal accuracy
            for(int index = 0; index < ArraySize(signalArray); index++){
               if(signalArray[index].status == 2
               && signalArray[(index)].type == 1
               )accuray++;
            }          
            
            signal.type          =  1;
            signal.time.hours    =  currentDateTime.hours;
            signal.time.minutes  =  currentDateTime.minutes;
            signal.time.seconds  =  currentDateTime.seconds;
            signal.accuracy      =  accuray;
            signal.status        =  2; 
         }
         
         if(ArrayResize(signalArray,1)) signalArray[(ArraySize(signalArray) - 1)] = signal;
         middleSqueezeConfimation[1] = true;
         squeeze = true;
       }
       }
       
       if(TDI::tdiHandleGreen > (TDI::tdiHandleUpperBlue + 4)){
         middleSqueezeConfimation[1] = true;
         middleSqueezeConfimation[9] = true;
       }
   }
   
   if(middleSqueezeConfimation[9] == true && middleSqueezeConfimation[8] == false){
      if(TDI::tdiHandleGreen < TDI::tdiHandleUpperBlue){
       if(TDI::emaHandle > Bid){
         //orderManager.openOrder(TDI::LotSize,"sell","squezze shark high","market",TDI::Positons,0,TDI::StopLoss,TDI::TakeProfit);//sl , tp
         if(ArraySize(signalArray) == 0){
            signal.type          =  1;
            signal.time.hours    =  currentDateTime.hours;
            signal.time.minutes  =  currentDateTime.minutes;
            signal.time.seconds  =  currentDateTime.seconds;
            signal.accuracy      =  accuray;
            signal.status        =  2;
         }
         else{
            //Check the last signals to determine the next signal accuracy
            for(int index = 0; index < ArraySize(signalArray); index++){
               if(signalArray[index].status == 2
               && signalArray[(index)].type == 1
               )accuray++;
            }          
            
            signal.type          =  1;
            signal.time.hours    =  currentDateTime.hours;
            signal.time.minutes  =  currentDateTime.minutes;
            signal.time.seconds  =  currentDateTime.seconds;
            signal.accuracy      =  accuray;
            signal.status        =  2; 
         }
         
         if(ArrayResize(signalArray,1)) signalArray[(ArraySize(signalArray) - 1)] = signal;
         middleSqueezeConfimation[8] = true;
         squeeze = true;
      }
      }
   }
   
   
   //--------------------------------------------------------------------------------------------------------------
   
   //Reset the array
   if(currentDateTime.hours == 0){ 
      middleSqueezeConfimation[0]   =  false;
      middleSqueezeConfimation[1]   =  false;
      middleSqueezeConfimation[2]   =  false;
      middleSqueezeConfimation[3]   =  false;
      middleSqueezeConfimation[4]   =  true;
      middleSqueezeConfimation[5]   =  true;
      middleSqueezeConfimation[8]   =  false;
      middleSqueezeConfimation[9]   =  false;
      middleSqueezeConfimation[10]  =  false;
      middleSqueezeConfimation[11]  =  false;
   }
   
return squeeze;
}
//+------------------------------------------------------------------+

void TDI::squeezeSharkfin(int levelOfCompresion, int sharkfinSize){
   int   accuray     =  1;
   Signal signal;
   //---------------------------------------------------------------------------------------------------------
   //FOR BUY
   //Step one detect the condition
   if(squeezeSharkfinConfimation[0] == false && squeezeSharkfinConfimation[4] == true){
      if(
            TDI::tdiHandleLowerBlue < TDI::middleLevel
         && TDI::tdiHandleUpperBlue > TDI::middleLevel
         && TDI::tdiHandleUpperBlue - TDI::tdiHandleLowerBlue <= levelOfCompresion // compressed
      ){ 
         //All the lines should be compressed inside the two blue lines
         if((TDI::tdiHandleLowerBlue < TDI::tdiHandleGreen && TDI::tdiHandleUpperBlue > TDI::tdiHandleGreen)
            && (TDI::tdiHandleLowerBlue < TDI::tdiHandleRed && TDI::tdiHandleUpperBlue > TDI::tdiHandleRed)
            && (TDI::tdiHandleLowerBlue < TDI::tdiHandleYellow && TDI::tdiHandleUpperBlue > TDI::tdiHandleYellow)
           ){  
               //Look for Green below Red and below yellow
               if(TDI::tdiHandleGreen < TDI::tdiHandleRed
               && TDI::tdiHandleGreen < TDI::tdiHandleYellow
               ){
                  squeezeSharkfinConfimation[0] = true;
                  //squeezeSharkfinConfimation[4] = false;
               }
           }
      }
   }
   
   //Looking for a sharkfin first condition 
   if(squeezeSharkfinConfimation[0] == true 
   ){
      //Step two detect a low sharkfin
      if(TDI::tdiHandleGreen < (TDI::tdiHandleLowerBlue - sharkfinSize)){
         squeezeSharkfinConfimation[1] = true;
      }
       
      //Step two detect a high sharkfin
      if(TDI::tdiHandleGreen > (TDI::tdiHandleUpperBlue + sharkfinSize)){
         squeezeSharkfinConfimation[2] = true;
      }
   }
   
   
   //look for sharkfin second condition
   if(
        (squeezeSharkfinConfimation[1] == true 
      || squeezeSharkfinConfimation[2] == true)
      && squeezeSharkfinConfimation[3] == false 
    ){ 
    
      //sharkfin low
      if(squeezeSharkfinConfimation[1] == true){
         if(TDI::tdiHandleGreen > TDI::tdiHandleLowerBlue){
         if(TDI::emaHandle < Bid){
            if(ArraySize(signalArray) == 0){
               signal.type          =  0;
               signal.time.hours    =  currentDateTime.hours;
               signal.time.minutes  =  currentDateTime.minutes;
               signal.time.seconds  =  currentDateTime.seconds;
               signal.accuracy      =  accuray;
               signal.status        =  2;
            }
            else{
               //Check the last signals to determine the next signal accuracy
               for(int index = 0; index < ArraySize(signalArray); index++){
                  if(signalArray[index].status == 2
                  && signalArray[(index)].type == 0
                  )accuray++;
               }          
               
               signal.type          =  0;
               signal.time.hours    =  currentDateTime.hours;
               signal.time.minutes  =  currentDateTime.minutes;
               signal.time.seconds  =  currentDateTime.seconds;
               signal.accuracy      =  accuray;
               signal.status        =  2; 
            }
         
            if(ArrayResize(signalArray,1)) signalArray[(ArraySize(signalArray) - 1)] = signal;
            squeezeSharkfinConfimation[3] = true;
         }
         }
      }
      
      
      //sharkfin high
      if(squeezeSharkfinConfimation[2] == true){
         if(TDI::tdiHandleGreen < TDI::tdiHandleUpperBlue){
         if(TDI::emaHandle < Bid){
            if(ArraySize(signalArray) == 0){
               signal.type          =  1;
               signal.time.hours    =  currentDateTime.hours;
               signal.time.minutes  =  currentDateTime.minutes;
               signal.time.seconds  =  currentDateTime.seconds;
               signal.accuracy      =  accuray;
               signal.status        =  2;
            }
            else{
               //Check the last signals to determine the next signal accuracy
               for(int index = 0; index < ArraySize(signalArray); index++){
                  if(signalArray[index].status == 2
                  && signalArray[(index)].type == 1
                  )accuray++;
               }          
               
               signal.type          =  1;
               signal.time.hours    =  currentDateTime.hours;
               signal.time.minutes  =  currentDateTime.minutes;
               signal.time.seconds  =  currentDateTime.seconds;
               signal.accuracy      =  accuray;
               signal.status        =  2; 
            }
         
            if(ArrayResize(signalArray,1)) signalArray[(ArraySize(signalArray) - 1)] = signal;
            squeezeSharkfinConfimation[3] = true;
         }
         }
      }    
   }
   
   
   //Reset the array
   if(
         (squeezeSharkfinConfimation[0] == true
      && squeezeSharkfinConfimation[1] == true
      && squeezeSharkfinConfimation[2] == true
      && squeezeSharkfinConfimation[3] == true)
      || currentDateTime.hours == 0
      
   ){ 

      squeezeSharkfinConfimation[0] = false;
      squeezeSharkfinConfimation[1] = false;
      squeezeSharkfinConfimation[2] = false;
      squeezeSharkfinConfimation[3] = false;
   }
}

void TDI::manage(){
   //Create way to expire signals
   //Open TDI Orders
   if(ArraySize(signalArray) > 0){ // Only open positions if there are no trades running OrdersTotal()>0
      //Open Buy Orders
      if(signalArray[(ArraySize(signalArray) - 1)].type   == 0
      && signalArray[(ArraySize(signalArray) - 1)].status == 2
      ){
         orderManager.openOrder(TDI::LotSize,"buy","Trend Buy","market",TDI::Positons,0,TDI::StopLoss,TDI::TakeProfit);
         signalArray[(ArraySize(signalArray) - 1)].status = 1;
      }
   
   
   //Open Sell Orders
   if(signalArray[(ArraySize(signalArray) - 1)].type   == 1
   && signalArray[(ArraySize(signalArray) - 1)].status == 2
      ){
         if(!trend.emaTrend(PERIOD_M15) && !trend.emaTrend(PERIOD_H1)){ 
            orderManager.openOrder(TDI::LotSize,"sell","Trend Sell","market",TDI::Positons,0,TDI::StopLoss,TDI::TakeProfit);
            signalArray[(ArraySize(signalArray) - 1)].status = 1;
         }
        
      }
   }
}

void TDI::expire(){
  
   if(ArraySize(signalArray) > 0){
      for(int index = 0; index < ArraySize(signalArray); index++ ){
         
         if(signalArray[index].status ==  1
         && (signalArray[index].time.hours + 5)     ==  currentDateTime.hours
         && signalArray[index].time.minutes        ==  currentDateTime.minutes
         && signalArray[index].time.seconds        ==  currentDateTime.seconds
         ){ 
            signalArray[index].status = 0;
            break;
         }
         
      }
      
   }
}