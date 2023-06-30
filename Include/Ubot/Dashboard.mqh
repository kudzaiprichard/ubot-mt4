//+------------------------------------------------------------------+
//|                                                    Dashboard.mqh |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Software Corp."
#property link      "https://www.mql4.com"
#property version   "1.00"
#property strict

struct DashboardRow{
   string   text;
   color    textColor;
   string   font;
   int      size;
   
   int      ySize;
   int      yDistance;
};

class Dashboard{
private:
   DashboardRow   mRows[];
   
   string         mName;
   int            mYDistance;
   
   string         textObjectName(int index){return(StringFormat("%s_%i",mName, index));}
   int            calcRowYDistance(int index);
   void           setRowYDistance(int index);
   void           drawRow(int index);
   void           deleteAll();
   
public:
   Dashboard(string name, int yDistance);
   ~Dashboard();
   void  Init(string name, int yDistance);
   
   void     addRow(string text, color textColor, string font, int size);
   string   getRowText(int index){return(mRows[index].text);}
   color    getRowTextColor(int index){return(mRows[index].textColor);}
   string   getRowFont(int index){return(mRows[index].font);}
   int      getRowSize(int index){return(mRows[index].size);}
   int      getRowYDistance(int index){return(mRows[index].yDistance);}
   
   void     setRow(int index, string text, color textColor,  string font, int size);
   void     setRowText(int index, string text);
   
   void     deleteRows(int first, int last);
   
   
   string   getName(){return(mName);}
   int      getYDistance(){return(mYDistance);}
   void     setYDistance(int value);
   
};
//+------------------------------------------------------------------+
                                                               
//+------------------------------------------------------------------+
Dashboard::Dashboard(string name, int yDistance){Init(name, yDistance);}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Dashboard::~Dashboard()
  {
  }
//+------------------------------------------------------------------+

void     Dashboard::Init(string name, int yDistance){
   mName    =  name;
   deleteAll();
   setYDistance(yDistance);
}

int   Dashboard::calcRowYDistance(int index){
   return((index == 0) ? mYDistance : mRows[index-1].yDistance + mRows[index - 1].ySize + 2);
}

void  Dashboard::setRowYDistance(int index){
   int   yDistance;
   for(int i=index; i<ArraySize(mRows); i++){
      yDistance   =  calcRowYDistance(i);
      if(yDistance!=mRows[i].yDistance){
         mRows[i].yDistance   =  yDistance;
         drawRow(i);
      }
      else{
         break;
      }
   }
   
   return;
}

void  Dashboard::drawRow(int index){
   string   objectName  =  textObjectName(index);
   if(ObjectFind(objectName) < 0){
      ObjectCreate(objectName, OBJ_LABEL, 0, 0, 0);
   }
   
   int   currentYSize   =  mRows[index].ySize;
   
   ObjectSetText(objectName, mRows[index].text, mRows[index].size, mRows[index].font, mRows[index].textColor);
   ObjectSet(objectName, OBJPROP_CORNER, 3);
   ObjectSet(objectName, OBJPROP_XDISTANCE, 8);
   ObjectSet(objectName, OBJPROP_YDISTANCE, mRows[index].yDistance);
   
   int   newYSize    =  (int)ObjectGetInteger(0, objectName, OBJPROP_YSIZE);
   if(newYSize>0){
      mRows[index].ySize   =  newYSize;
   }
   else if(mRows[index].ySize == 0){
      mRows[index].ySize   =  mRows[index].size*96/72;
   }
   
   if(currentYSize   != mRows[index].ySize){
      setRowYDistance(index+1);
   }
}


void Dashboard::deleteAll(void){
   deleteRows(0, ArraySize(mRows)-1);
   ObjectsDeleteAll(0, mName+"_");
}


void  Dashboard::addRow(string text,color textColor,string font,int size){
   int index   =  ArraySize(mRows);
   ArrayResize(mRows , index+1);
   
   mRows[index].text       =  text;
   mRows[index].textColor  =  textColor;
   mRows[index].font       =  font;
   mRows[index].size       =  size;
   setRowYDistance(index);
   
   drawRow(index);
   return;
}


void  Dashboard::setRow(int index,string text,color textColor,string font,int size){
   mRows[index].text       =  text;
   mRows[index].textColor  =  textColor;
   mRows[index].font       =  font;
   mRows[index].size       =  size;
   
   drawRow(index);
   return;
}


void  Dashboard::setRowText(int index,string text){
   mRows[index].text = text;
   drawRow(index);
   
   return;
}


void  Dashboard::setYDistance(int value){
   mYDistance     =  value;
   setRowYDistance(0);
}

/*
void  Dashboard::setRowYDistance(int index){
   int yDistance;
   for(int i=index; i<ArraySize(mRows); i++){
      yDistance   =  calcRowYDistance(i);
      if(yDistance   != mRows[i].yDistance){
         mRows[i].yDistance   =  yDistance;
         drawRow(i);
      }
      else{
         break;
      }
   }
   
   return;
}
*/

void Dashboard::deleteRows(int first,int last){
   if(last>=ArraySize(mRows)) last = ArraySize(mRows)-1;
   if(first<0) first =  0;
   if(last<first) return;
   
   DashboardRow   rows[];
   
   ArrayResize(rows, ArraySize(mRows));
   for(int  i  =  0; i<ArraySize(mRows); i++){
      rows[i]  =  mRows[i];
   }
   
   ObjectsDeleteAll(0, mName+"_");
   ArrayResize(mRows, 0);
   
   for(int i = 0; i < ArraySize(rows); i++){
      if(i < first || i > last){
         addRow(rows[i].text, rows[i].textColor, rows[i].font, rows[i].size);
      }
   }
   
   return;
}