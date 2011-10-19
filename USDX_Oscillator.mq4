//+------------------------------------------------------------------+
//|                                              USDX_Oscillator.mq4 |
//|                      Copyright © 2011, SynthTrade Software Corp. |
//|                                        http://www.synthtrade.biz |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, SynthTrade Software Corp."
#property link      "http://www.synthtrade.biz"

extern int MaxBars = 700;

//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 2
#property  indicator_color1  Green
#property  indicator_color2  Red
 
//---- indicator buffers
double     ExtBuffer1[];
double     ExtBuffer2[];

//---- non-indicator buffers
double RSIndexBuffer[];
double USDIndexBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   //---- drawing settings
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   IndicatorDigits(Digits+2);
   SetIndexDrawBegin(0,34);
   SetIndexDrawBegin(1,34);
//---- 3 indicator buffers mapping
   SetIndexBuffer(0,ExtBuffer1);
   SetIndexBuffer(1,ExtBuffer2);

   ArraySetAsSeries(USDIndexBuffer, true);
   ArraySetAsSeries(RSIndexBuffer, true);

//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("USDX Oscillator");
   SetIndexLabel(1,NULL);
   SetIndexLabel(2,NULL);
//---- initialization done

  
   return(0);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    limit, i;
   int    counted_bars=IndicatorCounted();
   double sma5, sma34;
   
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--; 
   limit=Bars-counted_bars;
   if (limit > MaxBars) limit = MaxBars;

//---- macd

   ArrayResize(USDIndexBuffer, limit+35); 
   ArrayResize(RSIndexBuffer, limit);

   for (i=0; i<ArraySize(USDIndexBuffer); i++) {
      USDIndexBuffer[i]=
         50.14348112 *
         MathPow((iHigh("EURUSD",0,i) + iLow("EURUSD",0,i))/2,-0.576) * 
         MathPow((iHigh("USDJPY",0,i) + iLow("USDJPY",0,i))/2,0.136) * 
         MathPow((iHigh("GBPUSD",0,i) + iLow("GBPUSD",0,i))/2,-0.119) * 
         MathPow((iHigh("USDCAD",0,i) + iLow("USDCAD",0,i))/2,0.091) * 
         MathPow((iHigh("USDSEK",0,i) + iLow("USDSEK",0,i))/2,0.042) * 
         MathPow((iHigh("USDCHF",0,i) + iLow("USDCHF",0,i))/2,0.036);
   }

   for (i=limit-1; i>=0; i--) {
      sma5 = iMAOnArray (USDIndexBuffer,0,5,0,MODE_SMA,i);
      sma34 = iMAOnArray (USDIndexBuffer,0,34,0,MODE_SMA,i);
      RSIndexBuffer[i] = sma5 - sma34;
   }
   

   for(i=limit-1; i>=0; i--)
     {
      ExtBuffer1[i]=0.0;
      ExtBuffer2[i]=0.0;

      if (RSIndexBuffer[i] > RSIndexBuffer[i+1]) {
         ExtBuffer1[i]=RSIndexBuffer[i];
      }
      else {
         ExtBuffer2[i]=RSIndexBuffer[i];   
      }
     }

//---- done
   return(0);
  }
//+------------------------------------------------------------------+