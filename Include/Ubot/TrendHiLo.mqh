//+------------------------------------------------------------------+
//|                                                    TrendHiLo.mqh |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Software Corp."
#property link      "https://www.mql4.com"
#property version   "1.00"
#property strict

#include <Object.mqh>

struct sTrendPoint{
   int      bar;
   double   price;
   datetime time;
};

struct sTrend{
   double      slope;
   sTrendPoint base;
};

class TrendHiLo : public CObject{

private:

protected: 
   string            mSymbol;
   ENUM_TIMEFRAMES   mTimeframe;
   
   int   mStart;
   int   mLength;
   
   sTrend   mUpperTrend;
   sTrend   mLowerTrend;
   
   double   ValueAt(const int index, const sTrend &trend);
   
   
public:
   TrendHiLo(const int start=1, const int length=20);
   ~TrendHiLo();
   
   void        update();
   void        updateLower();
   void        updateUpper();
   
   double      upperValueAt(const int index);
   double      upperValueAt(const datetime time);
   double      lowerValueAt(const int index);
   double      lowerValueAt(const datetime time);
   
   int         Start()           {return(mStart);}
   void        Start(int value)  {mStart=value; update();}
   int         length()          {return(mLength);}
   void        length(int value) {mLength=value; update();}
           
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TrendHiLo::TrendHiLo(const int Start=1, const int length=20){
   mSymbol     =  Symbol();
   mTimeframe  =  (ENUM_TIMEFRAMES)Period();
   
   mStart      =  Start;
   mLength     =  length;
   
   update();
}
TrendHiLo::~TrendHiLo(){}
//+------------------------------------------------------------------+

void TrendHiLo::update(){
   updateLower();
   updateUpper();
}

void TrendHiLo::updateLower(){
   int      firstBar    =  iLowest(mSymbol, mTimeframe, MODE_LOW, mLength, mStart);
   int      nextBar     =  firstBar;
   
   double   firstValue  =  0;
   int      midBar      =  mStart + (mLength/2);
   double   bestSlope   =  0;
   
   if(firstBar >= midBar){
   
      while(nextBar>=midBar){
         firstBar    = nextBar;
         firstValue  = iLow(mSymbol, mTimeframe, firstBar);
         bestSlope   = 0;
         
         for(int i=firstBar-1; i>=mStart; i--){ //count left to right
            int      pos   =  firstBar - i;
            double   slope =  (iLow(mSymbol, mTimeframe, i)-firstValue)/pos; //+ve slope
            
            if(nextBar == firstBar || slope<bestSlope){// least +ve slope
               nextBar     =  i;
               bestSlope   =  slope;
            }
         }
      }
   } else {
      while(nextBar<midBar){
         firstBar    =  nextBar;
         firstValue  =  iLow(mSymbol, mTimeframe, firstBar);
         bestSlope   = 0;
         
         for(int i = firstBar+1; i<(mStart+mLength); i++){// count right to left
            int      pos   =  i-firstBar;
            double   slope =  (firstValue - iLow(mSymbol, mTimeframe, i))/pos; //-ve slope
            
            if(nextBar == firstBar || slope>bestSlope){ //least - ve slope
               nextBar     = i;
               bestSlope   = slope;
            }
         }
      }
   }
   
   mLowerTrend.slope       =  bestSlope;
   mLowerTrend.base.bar    =  firstBar;
   mLowerTrend.base.price  =  firstValue;
   mLowerTrend.base.time   =  iTime(mSymbol, mTimeframe, firstBar); 
}


void TrendHiLo::updateUpper(){
   int      firstBar    =  iHighest(mSymbol, mTimeframe, MODE_HIGH, mLength, mStart);
   int      nextBar     =  firstBar;
   
   double   firstValue  =  0;
   int      midBar      =  mStart + (mLength/2);
   double   bestSlope   =  0;
   
   if(firstBar >= midBar){
   
      while(nextBar>=midBar){ //down slope
         firstBar    = nextBar;
         firstValue  = iHigh(mSymbol, mTimeframe, firstBar);
         bestSlope   = 0;
         
         for(int i=firstBar-1; i>=mStart; i--){ //count left to right
            int      pos   =  firstBar - i;
            double   slope =  (iHigh(mSymbol, mTimeframe, i)-firstValue)/pos; //-ve slope
            
            if(nextBar == firstBar || slope>bestSlope){// least -ve slope
               nextBar     =  i;
               bestSlope   =  slope;
            }
         }
      }
   } else {
      while(nextBar<midBar){
         firstBar    =  nextBar;
         firstValue  =  iHigh(mSymbol, mTimeframe, firstBar);
         bestSlope   = 0;
         
         for(int i = firstBar+1; i<(mStart+mLength); i++){// count right to left
            int      pos   =  i-firstBar;
            double   slope =  (firstValue - iHigh(mSymbol, mTimeframe, i))/pos; //+ve slope
            
            if(nextBar == firstBar || slope>bestSlope){ //least +ve slope
               nextBar     = i;
               bestSlope   = slope;
            }
         }
      }
   }
   
   mUpperTrend.slope       =  bestSlope;
   mUpperTrend.base.bar    =  firstBar;
   mUpperTrend.base.price  =  firstValue;
   mUpperTrend.base.time   =  iTime(mSymbol, mTimeframe, firstBar); 
}

double TrendHiLo::ValueAt(const int index,const sTrend &trend){
   int      offset   =  (trend.base.bar-index);
   double   value    =  trend.base.price+(trend.slope*offset);
   return(value);
}

double   TrendHiLo::upperValueAt(const datetime time){
   int      index    =  iBarShift(mSymbol, mTimeframe, time, false);
   return(ValueAt(index, mUpperTrend));
}

double TrendHiLo::lowerValueAt(const datetime time){
   int   index    =  iBarShift(mSymbol, mTimeframe, time, false);
   return(ValueAt(index, mLowerTrend));
}

double TrendHiLo::lowerValueAt(const int index){
   return(ValueAt(index, mLowerTrend));
}

double   TrendHiLo::upperValueAt(const int index){
 return(ValueAt(index, mUpperTrend));
}
