//+------------------------------------------------------------------+
//|                                               CandleParttens.mqh |
//|                                          Copyright 2022, Intela. |
//|                                             https://www.ubot.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Intela."
#property link      "https://www.ubot.com"
#property version   "1.00"
//Includes

class CandleParttens{
private:
      //Bullish candle stick parttens
      bool bullishHammer();
      bool bullishEngulfing();
      bool bullishMorningStar(double maxBodyValue);
      bool bullishPiercingLine();
      bool bullishInverseHammer();
      bool bullishThreeWhiteSoilders();
      bool bullishRailRoad();
      
      //Bearish candle stick parttens
      bool bearishHangman();
      bool bearishEngulfing();
      bool bearishEveningStar(double maxBodyValue);
      bool bearishShootingStar();
      bool bearishDarkCloudCover();
      bool bearishThreeBlackCrows();
      bool bearishRailRoad();
      
      //Continuation candle stick parttens
      bool continuationDoji();
      bool continuationSpinningTop();
      bool continuationRisingThree();
      bool continuationFallingThree();
      
      void createObj(datetime dateTime, double price, int arrowCode, int direction,color clr, string name);
      void variableInit(int index, ENUM_TIMEFRAMES   mTimeframe
      );
      
      //Private variables
      double firstCandleHigh;
      double firstCandleLow;
      double firstCandleOpen;
      double firstCandleClose;
      
      double secondCandleHigh;
      double secondCandleLow;
      double secondCandleOpen;
      double secondCandleClose;
      
      double thirdCandleHigh;
      double thirdCandleLow;
      double thirdCandleOpen;
      double thirdCandleClose;
      
      double fourthCandleHigh;
      double fourthCandleLow;
      double fourthCandleOpen;
      double fourthCandleClose;
      
      double fifthCandleHigh;
      double fifthCandleLow;
      double fifthCandleOpen;
      double fifthCandleClose;
      
      datetime time;
           
public:
      CandleParttens();
      ~CandleParttens(); 
      int stopHunt(int index, ENUM_TIMEFRAMES   mTimeframe);
      bool bullishStopHunt(int index, ENUM_TIMEFRAMES   mTimeframe);
      bool bearishStopHunt(int index, ENUM_TIMEFRAMES   mTimeframe);
};
//+------------------------------------------------------------------+
//|Constructor                                                       |
//+------------------------------------------------------------------+
CandleParttens::CandleParttens(){}

CandleParttens::~CandleParttens(){}
//+------------------------------------------------------------------+

/*NB: THESE CANDLE STICK PARTTENS USUALLY SHOW ON HIGHER TIME FRAME 
      HENCE MORE EFFECTIVE ON DAILY TIME FRAME. BUT WE CAN ALSO MAKE
      USE OF THEM IN M15 WERE WE INITIALLY MAKE OUR TRADES*/
//+------------------------------------------------------------------+
//|VARIABLE INTIALIZER FUNCTION                                      |
//+------------------------------------------------------------------+
//Initiates the variable with values on every new tick
//+------------------------------------------------------------------+
void CandleParttens::variableInit(int index, ENUM_TIMEFRAMES   mTimeframe){
   //Time
   CandleParttens::time = iTime(_Symbol,PERIOD_CURRENT,index);
   
   //First candle calculations      
   CandleParttens::firstCandleHigh = iHigh(_Symbol, mTimeframe, index);
   CandleParttens::firstCandleLow = iLow(_Symbol, mTimeframe, index);
   CandleParttens::firstCandleOpen = iOpen(_Symbol, mTimeframe, index);
   CandleParttens::firstCandleClose = iClose(_Symbol, mTimeframe, index);
   
   //Second Candle calculations
   CandleParttens::secondCandleHigh = iHigh(_Symbol, mTimeframe, (index+1));
   CandleParttens::secondCandleLow = iLow(_Symbol, mTimeframe, (index+1));
   CandleParttens::secondCandleOpen = iOpen(_Symbol, mTimeframe, (index+1));
   CandleParttens::secondCandleClose = iClose(_Symbol, mTimeframe, (index+1));
   
   //Third Candle calculations
   CandleParttens::thirdCandleHigh = iHigh(_Symbol, mTimeframe, (index+2));
   CandleParttens::thirdCandleLow = iLow(_Symbol, mTimeframe, (index+2));
   CandleParttens::thirdCandleOpen = iOpen(_Symbol, mTimeframe, (index+2));
   CandleParttens::thirdCandleClose = iClose(_Symbol, mTimeframe, (index+2));
   
   //Fourth Candle calculations~which should be a bearish candle
   CandleParttens::fourthCandleHigh = iHigh(_Symbol, mTimeframe, (index+3));
   CandleParttens::fourthCandleLow = iLow(_Symbol, mTimeframe, (index+3));
   CandleParttens::fourthCandleOpen = iOpen(_Symbol, mTimeframe, (index+3));
   CandleParttens::fourthCandleClose = iClose(_Symbol, mTimeframe, (index+3));
   
   //calculate the fith candle~which should be a bearish
   CandleParttens::fifthCandleHigh = iHigh(_Symbol, mTimeframe, (index+4));
   CandleParttens::fifthCandleLow = iLow(_Symbol, mTimeframe, (index+4));
   CandleParttens::fifthCandleOpen = iOpen(_Symbol, mTimeframe, (index+4));
   CandleParttens::fifthCandleClose = iClose(_Symbol, mTimeframe, (index+4));
}

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|ON SCREEN OBJECT CREATION                                         |
//+------------------------------------------------------------------+
//create object on chart
//+------------------------------------------------------------------+
void CandleParttens::createObj(datetime dateTime, double price, int arrowCode, int direction, color clr, string name){
   string objName;
   string arrowName = StringConcatenate(objName,"Signal@",dateTime,"at",DoubleToString(price, _Digits),"(",arrowCode,")");
   string objNameDesc = objName + name;
                
   if(ObjectCreate(0,objNameDesc,OBJ_TEXT,0,dateTime,price)
   && ObjectCreate(0,arrowName,OBJ_ARROW,0,dateTime,price)){
      
      ObjectSetInteger(0,arrowName,OBJPROP_ARROWCODE,arrowCode);
      ObjectSetInteger(0,arrowName,OBJPROP_COLOR,clr);
      
      ObjectSetString(0,objNameDesc,OBJPROP_TEXT," "+name);
      ObjectSetInteger(0,objNameDesc,OBJPROP_COLOR,clr);
      
      if(direction > 0){
         ObjectSetInteger(0,objNameDesc,OBJPROP_ANCHOR,ANCHOR_TOP);
         ObjectSetInteger(0,arrowName,OBJPROP_ANCHOR,ANCHOR_TOP);
      }
      
      if(direction < 0){
         ObjectSetInteger(0,objNameDesc,OBJPROP_ANCHOR,ANCHOR_BOTTOM);
         ObjectSetInteger(0,arrowName,OBJPROP_ANCHOR,ANCHOR_BOTTOM);
      }
   }
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
// BULLISH CANDLE STICK PARTTENS                                     |
//+------------------------------------------------------------------+
//Alerts all bullish candle partten as a stop hunt
//+------------------------------------------------------------------+
int CandleParttens::stopHunt(int index, ENUM_TIMEFRAMES   mTimeframe){
   CandleParttens::variableInit(index, mTimeframe);
      CandleParttens::bullishThreeWhiteSoilders(); 
      CandleParttens::bullishInverseHammer();
      CandleParttens::bullishInverseHammer();
      CandleParttens::bullishPiercingLine();
      CandleParttens::bullishMorningStar(40);
      CandleParttens::bullishEngulfing();
      CandleParttens::bullishHammer();
      CandleParttens::bullishRailRoad();
      CandleParttens::bearishThreeBlackCrows();
      CandleParttens::bearishHangman();
      CandleParttens::bearishEngulfing();
      CandleParttens::bearishShootingStar();
      CandleParttens::bearishDarkCloudCover();
      CandleParttens::bearishEveningStar(40);
      CandleParttens::bearishRailRoad();
      
   
   
   //if(CandleParttens::continuationDoji()) bStopHunt = 3;
   //if(CandleParttens::continuationSpinningTop()) bStopHunt = 3;
   //if(CandleParttens::continuationFallingThree()) bStopHunt = 3;
   //if(CandleParttens::continuationRisingThree()) bStopHunt = 3;
  return true;
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
bool CandleParttens::bullishStopHunt(int index, ENUM_TIMEFRAMES   mTimeframe){
   bool isStopHunt = false;
   CandleParttens::variableInit(index,mTimeframe);
   
   if(CandleParttens::bullishThreeWhiteSoilders() 
      || CandleParttens::bullishInverseHammer()
      || CandleParttens::bullishInverseHammer()
      || CandleParttens::bullishPiercingLine()
      || CandleParttens::bullishMorningStar(40)
      || CandleParttens::bullishEngulfing()
      || CandleParttens::bullishHammer()
      || CandleParttens::bullishRailRoad()
      ) {isStopHunt = true;}
      
   return isStopHunt;
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
bool CandleParttens::bearishStopHunt(int index, ENUM_TIMEFRAMES   mTimeframe){
   bool isStopHunt = false;
   CandleParttens::variableInit(index, mTimeframe);
   if(CandleParttens::bearishThreeBlackCrows() 
      || CandleParttens::bearishHangman()
      || CandleParttens::bearishEngulfing()
      || CandleParttens::bearishShootingStar()
      || CandleParttens::bearishDarkCloudCover()
      || CandleParttens::bearishEveningStar(40)
      || CandleParttens::bearishRailRoad()
      ){isStopHunt = true;}
   return isStopHunt;
}
//+------------------------------------------------------------------+
//Bulish hammer
//+------------------------------------------------------------------+
bool CandleParttens::bullishHammer(){
   bool isHammer = false;
        
   double firstCandleLowerShadow = CandleParttens::firstCandleOpen - CandleParttens::firstCandleLow;
   double firstCandleUpperShadow = CandleParttens::firstCandleHigh - CandleParttens::firstCandleClose;
   double firstCandlebody = CandleParttens::firstCandleClose - CandleParttens::firstCandleOpen;
         
   if(CandleParttens::firstCandleClose>CandleParttens::firstCandleOpen){
      if(firstCandleUpperShadow < (firstCandlebody * 0.5) 
      && firstCandleLowerShadow > (firstCandlebody * 2)
      ){
         createObj(CandleParttens::time, CandleParttens::firstCandleLow, 217,1, clrGreen, "hammer");
         isHammer = true;
      }
   }
   return isHammer;
}
//+------------------------------------------------------------------+

//Bulish inverse hammer
//+------------------------------------------------------------------+
bool CandleParttens::bullishInverseHammer(){
   bool isInverseHammer = false;
     
   double firstCandleLowerShadow = CandleParttens::firstCandleOpen - CandleParttens::firstCandleLow;
   double firstCandleUpperShadow = CandleParttens::firstCandleHigh - CandleParttens::firstCandleClose;
   double firstCandlebody = CandleParttens::firstCandleClose - CandleParttens::firstCandleOpen;
   
   if(CandleParttens::firstCandleClose>CandleParttens::firstCandleOpen){
      if(firstCandleUpperShadow > (firstCandlebody * 2) 
      && firstCandleLowerShadow < (firstCandlebody * 0.5)
      ){
         createObj(CandleParttens::time, CandleParttens::firstCandleLow, 217,1, clrGreen, "inverse hammer");
         isInverseHammer = true;
      }
   }
   
   return isInverseHammer;
}
//+------------------------------------------------------------------+

//Bulish engulfing
//+------------------------------------------------------------------+
bool CandleParttens::bullishEngulfing(){
/*
   double maxTop: refers to how much from the top do you want the behind candle to be engulfed
   double maxBottom: refers to how much from the bottom do you want the behind candle to be engulfed
*/
   bool isEngulfing = false;
   
   double firstCandleBody = NormalizeDouble(CandleParttens::firstCandleClose - CandleParttens::firstCandleOpen,_Digits);
   double firstCandleHieght = NormalizeDouble(CandleParttens::firstCandleHigh - CandleParttens::firstCandleLow,_Digits); //100 percent
   double firstCandleBodyPercantage = (firstCandleBody/firstCandleHieght)*100; //convert it to percentage
   
   double secondCandleBody = CandleParttens::secondCandleOpen - CandleParttens::secondCandleClose;      
   
   if(CandleParttens::firstCandleOpen < CandleParttens::firstCandleClose 
   && CandleParttens::secondCandleOpen > CandleParttens::secondCandleClose
   ){
      if(CandleParttens::firstCandleHigh > CandleParttens::secondCandleHigh 
      && CandleParttens::firstCandleLow < CandleParttens::secondCandleLow
      ){
        if(CandleParttens::firstCandleClose > CandleParttens::secondCandleOpen 
        && CandleParttens::firstCandleOpen < CandleParttens::secondCandleClose
        && firstCandleBodyPercantage > 50
        ){
          if(firstCandleBody > secondCandleBody){
            createObj(CandleParttens::time, CandleParttens::firstCandleLow, 217,1, clrGreen, "engulfing");
            isEngulfing = true;
           }
         }
       }
   }
   
               
   return isEngulfing;
}
//+------------------------------------------------------------------+

//Bulish piercing line
//+------------------------------------------------------------------+
bool CandleParttens::bullishPiercingLine(){

   bool piercingLine = false;
   double secondCandleBody = NormalizeDouble(CandleParttens::secondCandleOpen - CandleParttens::secondCandleClose,_Digits);
   
   if(CandleParttens::firstCandleClose > CandleParttens::firstCandleOpen
    && CandleParttens::secondCandleClose < CandleParttens::secondCandleOpen){
      if(CandleParttens::secondCandleOpen - (secondCandleBody/2) < CandleParttens::firstCandleClose
      && CandleParttens::firstCandleOpen < CandleParttens::secondCandleClose 
      && CandleParttens::firstCandleClose < CandleParttens::secondCandleOpen
      && CandleParttens::secondCandleHigh > CandleParttens::firstCandleHigh 
      && CandleParttens::firstCandleLow < CandleParttens::secondCandleLow
      ){
         createObj(CandleParttens::time, CandleParttens::firstCandleLow, 217,1, clrGreen, "piercing line");
         piercingLine = true;
      }
   }
   return piercingLine;
}
//+------------------------------------------------------------------+

//Bulish morning star
//+------------------------------------------------------------------+
bool CandleParttens::bullishMorningStar(double maxBodyValue){
   bool isStar = false;
   
   double firstCandleBody = NormalizeDouble(CandleParttens::firstCandleClose - CandleParttens::firstCandleOpen,_Digits);
   double firstCandleHieght = NormalizeDouble(CandleParttens::firstCandleHigh - CandleParttens::firstCandleLow,_Digits); //100 percent
   double firstCandleBodyPercantage = (firstCandleBody/firstCandleHieght)*100; //convert it to percentage
   
   double thirdCandleBody = NormalizeDouble(CandleParttens::thirdCandleOpen - CandleParttens::thirdCandleClose,_Digits);
   double thirdCandleHieght = NormalizeDouble(CandleParttens::thirdCandleHigh - CandleParttens::thirdCandleLow,_Digits); //100 percent
   double thirdCandleBodyPercantage = (thirdCandleBody/thirdCandleHieght)*100; //convert it to percentage
      
   //doji candle calculation
   double secondCandleBody = NULL;
   double secondCandleHieght = NormalizeDouble(CandleParttens::secondCandleHigh - CandleParttens::secondCandleLow,_Digits); //100 percent
   
   if(CandleParttens::secondCandleClose > CandleParttens::secondCandleOpen)
      secondCandleBody = NormalizeDouble(CandleParttens::secondCandleClose - CandleParttens::secondCandleOpen,_Digits);
   if(CandleParttens::secondCandleOpen > CandleParttens::secondCandleClose)
      secondCandleBody = NormalizeDouble(CandleParttens::secondCandleOpen - CandleParttens::secondCandleClose,_Digits);
   
   double secondCandleBodyPercantage = (secondCandleBody/secondCandleHieght)*100; //convert it to percentage

   //NB: closing on top of half of candle means thirdCandleOpen - (thirdCandleBody/2)  
   //TODO: Configure the gap thing~seems not to be neccessary
   //TODO: The alter candles should be big, but how big?. to adjust both candles just increase the third candle
   if(CandleParttens::firstCandleClose > CandleParttens::firstCandleOpen){
      if(thirdCandleClose < thirdCandleOpen){
         if(CandleParttens::firstCandleClose > CandleParttens::thirdCandleOpen - (thirdCandleBody/2)
            && thirdCandleBodyPercantage > maxBodyValue){
           if(secondCandleBodyPercantage < 6 
               && secondCandleBodyPercantage != NULL 
               && secondCandleBodyPercantage > -6)
           {
             /*Comment("\nThird %: ", firstCandleBodyPercantage,
                     "\nMiddle %: ", secondCandleBodyPercantage);*/
             createObj(CandleParttens::time, CandleParttens::firstCandleLow, 200, 1, clrGreen, "Morning Star");
             isStar = true;
           }
        }
      }  
   }
               
   return isStar;
}
//+------------------------------------------------------------------+

//Bulish three white soilders
//+------------------------------------------------------------------+
bool CandleParttens::bullishThreeWhiteSoilders(){
   bool threeWhiteSoilders = false;
   
   double firstCandleHieght = NormalizeDouble(CandleParttens::firstCandleHigh - CandleParttens::firstCandleLow,_Digits); //100 percent
   double firstCandleBody = NormalizeDouble(CandleParttens::firstCandleClose - CandleParttens::firstCandleOpen,_Digits);
   double firstCandleBodyPercantage = (firstCandleBody/firstCandleHieght)*100; //convert it to percentage
   
   double secondCandleHieght = NormalizeDouble(CandleParttens::secondCandleHigh - CandleParttens::secondCandleLow,_Digits); //100 percent
   double secondCandleBody = NormalizeDouble(CandleParttens::secondCandleClose - CandleParttens::secondCandleOpen,_Digits);
   double secondCandleBodyPercantage = (secondCandleBody/secondCandleHieght)*100; //convert it to percentage
   
   double thirdCandleHieght = NormalizeDouble(CandleParttens::thirdCandleHigh - CandleParttens::thirdCandleLow,_Digits); //100 percent
   double thirdCandleBody = NormalizeDouble(CandleParttens::thirdCandleClose - CandleParttens::thirdCandleOpen,_Digits);
   double thirdCandleBodyPercantage = (thirdCandleBody/thirdCandleHieght)*100; //convert it to percentage
   
   double fourthCandleHieght = NormalizeDouble(CandleParttens::fourthCandleHigh - CandleParttens::fourthCandleLow,_Digits); //100 percent
   double fourthCandleBody = NormalizeDouble(CandleParttens::fourthCandleOpen - CandleParttens::fourthCandleClose,_Digits); //open - close for bearish
   double fourthCandleBodyPercantage = (fourthCandleBody/fourthCandleHieght)*100; //convert it to percentage
   
   if(CandleParttens::firstCandleOpen < CandleParttens::firstCandleClose 
   && CandleParttens::secondCandleOpen < CandleParttens::secondCandleClose 
   && CandleParttens::thirdCandleOpen < CandleParttens::thirdCandleClose
   && CandleParttens::fourthCandleOpen > CandleParttens::fourthCandleClose
   && CandleParttens::fifthCandleOpen > CandleParttens::fifthCandleClose
   ){
      if(CandleParttens::thirdCandleClose > CandleParttens::fourthCandleOpen - (fourthCandleBody/2) 
      && CandleParttens::secondCandleClose > CandleParttens::fifthCandleOpen
      && firstCandleBodyPercantage > 50 
      && secondCandleBodyPercantage > 50 
      && thirdCandleBodyPercantage > 50
      ){
         /*Comment("\nThirdCandleClose: ", CandleParttens::thirdCandleClose,
                   "\nFourthCandleHalf: ", CandleParttens::fourthCandleOpen - (fourthCandleBody/2));*/
         createObj(CandleParttens::time, CandleParttens::firstCandleLow, 200, 1, clrGreen, "three white soldiers");
         threeWhiteSoilders = true;
      }
   }
   
   return threeWhiteSoilders;
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
bool CandleParttens::bullishRailRoad(){
   bool isRailRoad = false;
   double firstCandleHieght = NormalizeDouble(CandleParttens::firstCandleHigh - CandleParttens::firstCandleLow,_Digits); //100 percent
   double firstCandleBody = NormalizeDouble(CandleParttens::firstCandleClose - CandleParttens::firstCandleOpen,_Digits);
   double firstCandleBodyPercantage = (firstCandleBody/firstCandleHieght)*100; //convert it to percentage
   
   double secondCandleHieght = NormalizeDouble(CandleParttens::secondCandleHigh - CandleParttens::secondCandleLow,_Digits); //100 percent
   double secondCandleBody = NormalizeDouble(CandleParttens::secondCandleOpen - CandleParttens::secondCandleClose,_Digits);
   double secondCandleBodyPercantage = (secondCandleBody/secondCandleHieght)*100; //convert it to percentage
   
   /*
         May also use: 
         NormalizeDouble(CandleParttens::firstCandleOpen,0) == NormalizeDouble(CandleParttens::secondCandleClose,0) 
      || NormalizeDouble(CandleParttens::firstCandleHigh,0) == NormalizeDouble(CandleParttens::secondCandleHigh,0)
   */
   if(CandleParttens::firstCandleClose > CandleParttens::firstCandleOpen 
   && CandleParttens::secondCandleClose < CandleParttens::secondCandleOpen
   ){ 
      if(
      floor(CandleParttens::firstCandleOpen*0.1) == floor(CandleParttens::secondCandleClose*0.1) 
      ||floor(CandleParttens::firstCandleLow*0.1) == floor(CandleParttens::secondCandleLow*0.1)
      ){
         createObj(CandleParttens::time, CandleParttens::firstCandleLow, 200, 1, clrGreen, "rail road");
         isRailRoad = true;
      }
   }
   
 return isRailRoad;
}
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
// BEARISH CANDLE STICK PARTTENS                                     |
//+------------------------------------------------------------------+
//Bearish hangman
//+------------------------------------------------------------------+
bool CandleParttens::bearishHangman(){
   bool hangman = false;
        
   double firstCandleLowerShadow = CandleParttens::firstCandleClose - CandleParttens::firstCandleLow;
   double firstCandleUpperShadow = CandleParttens::firstCandleHigh - CandleParttens::firstCandleOpen;
   double firstCandlebody = CandleParttens::firstCandleOpen - CandleParttens::firstCandleClose;
        
   if(CandleParttens::firstCandleClose<CandleParttens::firstCandleOpen){
      if(firstCandleUpperShadow < (firstCandlebody * 0.5) 
      && firstCandleLowerShadow > (firstCandlebody * 2)
      ){
         createObj(CandleParttens::time, CandleParttens::firstCandleHigh, 218,-1, clrRed, "hangman");
         hangman = true;
      }
   }
   return hangman;
}
//+------------------------------------------------------------------+

//Bearish shooting star
//+------------------------------------------------------------------+
bool CandleParttens::bearishShootingStar(){
   bool shootingStar = false;
        
   double firstCandleLowerShadow = CandleParttens::firstCandleClose - CandleParttens::firstCandleLow;
   double firstCandleUpperShadow = CandleParttens::firstCandleHigh - CandleParttens::firstCandleOpen;
   double firstCandlebody = CandleParttens::firstCandleOpen - CandleParttens::firstCandleClose;
        
   if(CandleParttens::firstCandleClose<CandleParttens::firstCandleOpen){
      if(firstCandleUpperShadow > (firstCandlebody * 2) 
      && firstCandleLowerShadow < (firstCandlebody * 0.5)
      ){
         createObj(CandleParttens::time, CandleParttens::firstCandleHigh, 218,-1, clrRed, "shooting star");
         shootingStar = true;
      }
   }
   return shootingStar;
}
//+------------------------------------------------------------------+

//Bearish engulfing
//+------------------------------------------------------------------+
bool CandleParttens::bearishEngulfing(){
   bool isEngulfing = false;
   
   double firstCandleBody = NormalizeDouble(CandleParttens::firstCandleOpen - CandleParttens::firstCandleClose,_Digits);
   double firstCandleHieght = NormalizeDouble(CandleParttens::firstCandleHigh - CandleParttens::firstCandleLow,_Digits); //100 percent
   double firstCandleBodyPercantage = (firstCandleBody/firstCandleHieght)*100; //convert it to percentage
   
   double secondCandleBody = CandleParttens::secondCandleOpen - CandleParttens::secondCandleClose;//blue
   
   if(CandleParttens::firstCandleOpen > CandleParttens::firstCandleClose 
   && CandleParttens::secondCandleOpen < CandleParttens::secondCandleClose){
      if(CandleParttens::firstCandleHigh > CandleParttens::secondCandleHigh 
      && CandleParttens::firstCandleLow < CandleParttens::secondCandleLow){
        if(CandleParttens::firstCandleClose < CandleParttens::secondCandleOpen 
        && CandleParttens::firstCandleOpen > CandleParttens::secondCandleClose 
        && firstCandleBodyPercantage > 50
        ){
          if(firstCandleBody > secondCandleBody){
            createObj(CandleParttens::time, CandleParttens::firstCandleHigh, 218,-1, clrRed, "engulfing");
            isEngulfing = true;
           }
         }
       }    
   }
        
   return isEngulfing;
}
//+------------------------------------------------------------------+

//Bearish Evening star
//+------------------------------------------------------------------+
bool CandleParttens::bearishEveningStar(double maxBodyValue){
   bool isStar = false;
   
   double firstCandleBody = NormalizeDouble(CandleParttens::firstCandleOpen - CandleParttens::firstCandleClose,_Digits);
   double firstCandleHieght = NormalizeDouble(CandleParttens::firstCandleHigh - CandleParttens::firstCandleLow,_Digits); //100 percent
   double firstCandleBodyPercantage = (firstCandleBody/firstCandleHieght)*100; //convert it to percentage
   
   double thirdCandleBody = NormalizeDouble(CandleParttens::thirdCandleClose - CandleParttens::thirdCandleOpen,_Digits);
   double thirdCandleHieght = NormalizeDouble(CandleParttens::thirdCandleHigh - CandleParttens::thirdCandleLow,_Digits); //100 percent
   double thirdCandleBodyPercantage = (thirdCandleBody/thirdCandleHieght)*100; //convert it to percentage
      
   //doji candle calculation
   double secondCandleBody = NULL;
   double secondCandleHieght = NormalizeDouble(CandleParttens::secondCandleHigh - CandleParttens::secondCandleLow,_Digits); //100 percent
   
   if(CandleParttens::secondCandleClose > CandleParttens::secondCandleOpen)
      secondCandleBody = NormalizeDouble(CandleParttens::secondCandleClose - CandleParttens::secondCandleOpen,_Digits);
   if(CandleParttens::secondCandleOpen > CandleParttens::secondCandleClose)
      secondCandleBody = NormalizeDouble(CandleParttens::secondCandleOpen - CandleParttens::secondCandleClose,_Digits);
   
   double secondCandleBodyPercantage = (secondCandleBody/secondCandleHieght)*100; //convert it to percentage

   //NB: closing on top of half of candle means thirdCandleOpen - (thirdCandleBody/2)  
   //TODO: Configure the gap thing~seems not to be neccessary
   //TODO: The alter candles should be big, but how big?. to adjust both candles just increase the third candle
   if(CandleParttens::firstCandleClose < CandleParttens::firstCandleOpen){
      if(thirdCandleClose > thirdCandleOpen){
         if(CandleParttens::firstCandleOpen > CandleParttens::thirdCandleClose - (thirdCandleBody/2)
            && thirdCandleBodyPercantage > maxBodyValue){
           if(secondCandleBodyPercantage < 6 
               && secondCandleBodyPercantage != NULL 
               && secondCandleBodyPercantage > -6)
           {
             /*Comment("\nThird %: ", firstCandleBodyPercantage,
                     "\nMiddle %: ", secondCandleBodyPercantage);*/
             createObj(CandleParttens::time, CandleParttens::firstCandleHigh, 218, -1, clrRed, "evening Star");
             isStar = true;
           }
        }
      }  
   }
               
   return isStar;
}
//+------------------------------------------------------------------+

//Bearish three black crows
//+------------------------------------------------------------------+
bool CandleParttens::bearishThreeBlackCrows(){
   bool threeBlackCrows = false;
   
   double firstCandleHieght = NormalizeDouble(CandleParttens::firstCandleHigh - CandleParttens::firstCandleLow,_Digits); //100 percent
   double firstCandleBody = NormalizeDouble(CandleParttens::firstCandleOpen - CandleParttens::firstCandleClose,_Digits);
   double firstCandleBodyPercantage = (firstCandleBody/firstCandleHieght)*100; //convert it to percentage
   
   double secondCandleHieght = NormalizeDouble(CandleParttens::secondCandleHigh - CandleParttens::secondCandleLow,_Digits); //100 percent
   double secondCandleBody = NormalizeDouble(CandleParttens::secondCandleOpen - CandleParttens::secondCandleClose,_Digits);
   double secondCandleBodyPercantage = (secondCandleBody/secondCandleHieght)*100; //convert it to percentage
   
   double thirdCandleHieght = NormalizeDouble(CandleParttens::thirdCandleHigh - CandleParttens::thirdCandleLow,_Digits); //100 percent
   double thirdCandleBody = NormalizeDouble(CandleParttens::thirdCandleOpen - CandleParttens::thirdCandleClose,_Digits);
   double thirdCandleBodyPercantage = (thirdCandleBody/thirdCandleHieght)*100; //convert it to percentage
   
   double fourthCandleHieght = NormalizeDouble(CandleParttens::fourthCandleHigh - CandleParttens::fourthCandleLow,_Digits); //100 percent
   double fourthCandleBody = NormalizeDouble(CandleParttens::fourthCandleClose - CandleParttens::fourthCandleOpen,_Digits); //open - close for bearish
   double fourthCandleBodyPercantage = (fourthCandleBody/fourthCandleHieght)*100; //convert it to percentage
   
   if(CandleParttens::firstCandleOpen > CandleParttens::firstCandleClose 
   && CandleParttens::secondCandleOpen > CandleParttens::secondCandleClose 
   && CandleParttens::thirdCandleOpen > CandleParttens::thirdCandleClose
   && CandleParttens::fourthCandleOpen < CandleParttens::fourthCandleClose
   ){
      if(CandleParttens::thirdCandleOpen > CandleParttens::fourthCandleClose - (fourthCandleBody/2) 
      && CandleParttens::thirdCandleClose < CandleParttens::secondCandleOpen
      && CandleParttens::secondCandleClose < CandleParttens::firstCandleOpen
      && CandleParttens::firstCandleClose < CandleParttens::secondCandleOpen
      && firstCandleBodyPercantage > 20 
      && secondCandleBodyPercantage > 20 
      && thirdCandleBodyPercantage > 20
      ){
         createObj(CandleParttens::time, CandleParttens::firstCandleHigh, 218, -1, clrRed, "three black crows");
         threeBlackCrows = true;
      }
   }
   
   return threeBlackCrows;
}
//+------------------------------------------------------------------+

//Bearish dark cloud cover
//+------------------------------------------------------------------+
bool CandleParttens::bearishDarkCloudCover(){
   bool darkCloudCover = false;
   double secondCandleBody = NormalizeDouble(CandleParttens::secondCandleOpen - CandleParttens::secondCandleClose,_Digits);
   
   if(CandleParttens::firstCandleOpen > CandleParttens::firstCandleClose
    && CandleParttens::secondCandleClose > CandleParttens::secondCandleOpen){
      if(CandleParttens::secondCandleOpen - (secondCandleBody/2) > CandleParttens::firstCandleClose
      && CandleParttens::firstCandleOpen > CandleParttens::secondCandleClose 
      && CandleParttens::firstCandleClose > CandleParttens::secondCandleOpen
      && CandleParttens::secondCandleHigh < CandleParttens::firstCandleHigh 
      && CandleParttens::firstCandleLow > CandleParttens::secondCandleLow
      ){
         createObj(CandleParttens::time, CandleParttens::firstCandleHigh, 218,-1, clrRed, "dark cloud cover");
         darkCloudCover = true;
      }
   }
   return darkCloudCover;
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
bool CandleParttens::bearishRailRoad(){
 bool isRailRoad = false;
   double firstCandleHieght = NormalizeDouble(CandleParttens::firstCandleHigh - CandleParttens::firstCandleLow,_Digits); //100 percent
   double firstCandleBody = NormalizeDouble(CandleParttens::firstCandleOpen - CandleParttens::firstCandleClose,_Digits);
   double firstCandleBodyPercantage = (firstCandleBody/firstCandleHieght)*100; //convert it to percentage
   
   double secondCandleHieght = NormalizeDouble(CandleParttens::secondCandleHigh - CandleParttens::secondCandleLow,_Digits); //100 percent
   double secondCandleBody = NormalizeDouble(CandleParttens::secondCandleClose - CandleParttens::secondCandleOpen,_Digits);
   double secondCandleBodyPercantage = (secondCandleBody/secondCandleHieght)*100; //convert it to percentage
   
   /*
         May also use: 
         NormalizeDouble(CandleParttens::firstCandleClose,0) == NormalizeDouble(CandleParttens::secondCandleOpen,0) 
      || NormalizeDouble(CandleParttens::firstCandleHigh,0) == NormalizeDouble(CandleParttens::secondCandleHigh,0)
   */
   if(CandleParttens::firstCandleClose < CandleParttens::firstCandleOpen 
   && CandleParttens::secondCandleClose > CandleParttens::secondCandleOpen
   ){ 
      if(
      floor(CandleParttens::firstCandleClose*0.1) == floor(CandleParttens::secondCandleOpen*0.1) 
      ||floor(CandleParttens::firstCandleHigh*0.1) == floor(CandleParttens::secondCandleHigh*0.1)
      ){
         createObj(CandleParttens::time, CandleParttens::firstCandleHigh, 218, -1, clrRed, "rail road");
      }
   }
   
 return isRailRoad;
}
//+------------------------------------------------------------------+


//TODO-NOT IN USE NEEDS MORE RESEARCH: continuation FallingThree and continuation RisingThree
//+------------------------------------------------------------------+
// CONTINUATION CANDLE STICK PARTTENS                                |
//+------------------------------------------------------------------+
//Continuation doji
//+------------------------------------------------------------------+
bool CandleParttens::continuationDoji(){
   bool doji = false;
   //For bullish spinng top
   if(CandleParttens::firstCandleClose > CandleParttens::firstCandleOpen){
      double firstCandleHieght1 = NormalizeDouble(CandleParttens::firstCandleHigh - CandleParttens::firstCandleLow,_Digits); //100 percent
      double firstCandleBody1 = NormalizeDouble(CandleParttens::firstCandleClose - CandleParttens::firstCandleOpen,_Digits);
      double firstCandleBodyPercantage1 = (firstCandleBody1/firstCandleHieght1)*100; //convert it to percentage
   
      if(firstCandleBodyPercantage1 < 6 
      ){
         //Comment("\nFirst: ",firstCandleBodyPercantage);
         createObj(CandleParttens::time, CandleParttens::firstCandleHigh, 100, -1, clrDarkSlateGray, "Doji");
         doji = true;
      }
   }
   
   //For Bearish spinning top
   if(CandleParttens::firstCandleClose < CandleParttens::firstCandleOpen){
      double firstCandleHieght = NormalizeDouble(CandleParttens::firstCandleHigh - CandleParttens::firstCandleLow,_Digits); //100 percent
      double firstCandleBody = NormalizeDouble(CandleParttens::firstCandleOpen - CandleParttens::firstCandleClose,_Digits);
      double firstCandleBodyPercantage = (firstCandleBody/firstCandleHieght)*100; //convert it to percentage
   
      if(firstCandleBodyPercantage < 6){
         //Comment("\nFirst: ",firstCandleBodyPercantage);
         createObj(CandleParttens::time, CandleParttens::firstCandleHigh, 100, -1, clrDarkSlateGray, "Doji");
         doji = true;
      }
   }
   return true;
}
//+------------------------------------------------------------------+

//Continuation spinning top
//+------------------------------------------------------------------+
bool CandleParttens::continuationSpinningTop(){
   bool spinnningTop = false;
   //For bullish spinng top
   if(CandleParttens::firstCandleClose > CandleParttens::firstCandleOpen){
      double firstCandleHieght1 = NormalizeDouble(CandleParttens::firstCandleHigh - CandleParttens::firstCandleLow,_Digits); //100 percent
      double firstCandleBody1 = NormalizeDouble(CandleParttens::firstCandleClose - CandleParttens::firstCandleOpen,_Digits);
      double firstCandleBodyPercantage1 = (firstCandleBody1/firstCandleHieght1)*100; //convert it to percentage
      double firstCandleLowerShadow1 = CandleParttens::firstCandleOpen - CandleParttens::firstCandleLow;
      double firstCandleUpperShadow1 = CandleParttens::firstCandleHigh - CandleParttens::firstCandleClose;
      double firstCandleLowerShadowPercantage1 = (firstCandleLowerShadow1/firstCandleHieght1)*100;
      double firstCandleUpperShadowPercantage1 = (firstCandleUpperShadow1/firstCandleHieght1)*100;
   
      if(firstCandleBodyPercantage1 >= 6 
      &&firstCandleLowerShadowPercantage1 > 40
      && firstCandleUpperShadowPercantage1 > 40
      ){
         /*Comment( "\nLower: ",firstCandleLowerShadowPercantage, 
                  "\nUpper: ",firstCandleUpperShadowPercantage, 
                  "\nFirst: ",firstCandleBodyPercantage);*/
         createObj(CandleParttens::time, CandleParttens::firstCandleHigh, 100, -1, clrDarkSlateGray, "Spinning top");
         spinnningTop = true;
      }
   }
   
   //For Bearish spinning top
   if(CandleParttens::firstCandleClose < CandleParttens::firstCandleOpen){
      double firstCandleHieght = NormalizeDouble(CandleParttens::firstCandleHigh - CandleParttens::firstCandleLow,_Digits); //100 percent
      double firstCandleBody = NormalizeDouble(CandleParttens::firstCandleOpen - CandleParttens::firstCandleClose,_Digits);
      double firstCandleBodyPercantage = (firstCandleBody/firstCandleHieght)*100; //convert it to percentage
      double firstCandleLowerShadow = CandleParttens::firstCandleClose - CandleParttens::firstCandleLow;
      double firstCandleUpperShadow = CandleParttens::firstCandleHigh - CandleParttens::firstCandleOpen;
      double firstCandleLowerShadowPercantage = (firstCandleLowerShadow/firstCandleHieght)*100;
      double firstCandleUpperShadowPercantage = (firstCandleUpperShadow/firstCandleHieght)*100;
   
      if(firstCandleBodyPercantage >= 6
      && firstCandleLowerShadowPercantage > 40
      && firstCandleUpperShadowPercantage > 40
      ){
         /*Comment( "\nLower: ",firstCandleLowerShadowPercantage, 
                  "\nUpper: ",firstCandleUpperShadowPercantage, 
                  "\nFirst: ",firstCandleBodyPercantage);*/
         createObj(CandleParttens::time, CandleParttens::firstCandleHigh, 100, -1, clrDarkSlateGray, "Spinning top");
         spinnningTop = true;
      }
   }
   
   return spinnningTop;
}
//+------------------------------------------------------------------+

/*
   Needs more research on the below candle stick parttens 
   inorder to create them properly
*/
//Continuation falling three
//+------------------------------------------------------------------+
bool CandleParttens::continuationFallingThree(){
   bool fallinThree = false;
   
   if(CandleParttens::firstCandleOpen > CandleParttens::firstCandleClose 
   && CandleParttens::secondCandleOpen < CandleParttens::secondCandleClose
   && CandleParttens::thirdCandleOpen < CandleParttens::thirdCandleClose
   && CandleParttens::fourthCandleOpen < CandleParttens::fourthCandleClose
   && CandleParttens::fifthCandleOpen > CandleParttens::fifthCandleClose
   ){
      if(CandleParttens::firstCandleClose < CandleParttens::fifthCandleLow
      && CandleParttens::fifthCandleHigh > CandleParttens::firstCandleOpen
      && CandleParttens::firstCandleOpen >= CandleParttens::secondCandleClose
      && CandleParttens::fourthCandleOpen >= CandleParttens::fifthCandleClose
      && CandleParttens::secondCandleOpen > CandleParttens::thirdCandleClose
      && CandleParttens::thirdCandleOpen > CandleParttens::fourthCandleClose
      ){
         //Comment("/nFirst: ",CandleParttens::firstCandleClose, "/nFifth: ",CandleParttens::fifthCandleClose);
         createObj(CandleParttens::time, CandleParttens::firstCandleHigh, 100, -1, clrLimeGreen, "falling three");
         fallinThree = true;
      }
   }
   
   return fallinThree;
}
//+------------------------------------------------------------------+

//Continuation rising three
//+------------------------------------------------------------------+
bool CandleParttens::continuationRisingThree(){
   bool RisingThree = false;
   
   if(CandleParttens::firstCandleOpen < CandleParttens::firstCandleClose 
   && CandleParttens::secondCandleOpen > CandleParttens::secondCandleClose
   && CandleParttens::thirdCandleOpen > CandleParttens::thirdCandleClose
   && CandleParttens::fourthCandleOpen > CandleParttens::fourthCandleClose
   && CandleParttens::fifthCandleOpen < CandleParttens::fifthCandleClose
   ){
      if(CandleParttens::firstCandleClose > CandleParttens::fifthCandleClose
      && CandleParttens::fifthCandleOpen < CandleParttens::firstCandleOpen
      && CandleParttens::firstCandleOpen <= CandleParttens::secondCandleClose
      && CandleParttens::fourthCandleOpen <= CandleParttens::fifthCandleClose
      && CandleParttens::secondCandleOpen > CandleParttens::thirdCandleClose
      && CandleParttens::thirdCandleOpen < CandleParttens::fourthCandleClose
      ){
         //Comment("/nFirst: ",CandleParttens::firstCandleClose, "/nFifth: ",CandleParttens::fifthCandleClose);
         createObj(CandleParttens::time, CandleParttens::firstCandleHigh, 100, -1, clrLimeGreen, "falling three");
         RisingThree = true;
      }
   }
   
   return RisingThree;
}
//+------------------------------------------------------------------+