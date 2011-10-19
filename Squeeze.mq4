#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Lime
#property indicator_color2 Red
#property indicator_color3 Green
#property indicator_color4 Brown
#property indicator_color5 Lime
#property indicator_color6 Red

extern int Length = 21;

string gs_kaufman3_96 = "Kaufman3";
double gd_104 = 2.0;
double gd_112 = 16.0;
int gi_120 = 0;
bool gi_124 = TRUE;
double gda_128[];
double gda_132[];
double gda_136[];
double gda_140[];
double gda_144[];
double gda_148[];
double gda_152[];
double gda_156[];
double gda_160[];
double gda_164[100];
int gi_168 = 10;
double gda_172[];
double gda_176[];
double gda_180[];
double gda_184[];
bool gi_188 = TRUE;
datetime gt_192;
double gd_196 = 0.0;
double gd_204 = 0.0;
double gd_212 = 0.0;
double gd_220 = 0.0;
double gd_228 = 0.0;
double gd_236 = 0.0;
double gd_244 = 0.0;
double gd_252 = 0.0;
double gd_260 = 0.0;
double gd_268 = 0.0;
double gd_276 = 0.0;
double gd_284 = 0.0;
double gd_292 = 0.0;
double gd_300 = 0.0;
double gd_308 = 0.0;
double gd_316 = 0.0;
double gd_324 = 0.0;
double gd_332 = 0.0;
double gd_340 = 0.0;
double gd_348 = 0.0;
double gd_356 = 0.0;
double gd_364 = 0.0;
int gi_372 = 100;
int gi_376 = 0;
double gda_380[];
double gda_384[];

int init() {
   gi_168 = Length;
   IndicatorBuffers(8);
   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexStyle(1, DRAW_HISTOGRAM);
   SetIndexStyle(2, DRAW_HISTOGRAM);
   SetIndexStyle(3, DRAW_HISTOGRAM);
   SetIndexStyle(4, DRAW_ARROW);
   SetIndexStyle(5, DRAW_ARROW);
   SetIndexArrow(4, 159);
   SetIndexArrow(5, 159);
   SetIndexBuffer(0, gda_128);
   SetIndexBuffer(1, gda_132);
   SetIndexBuffer(2, gda_136);
   SetIndexBuffer(3, gda_140);
   SetIndexBuffer(4, gda_144);
   SetIndexBuffer(5, gda_148);
   SetIndexBuffer(6, gda_152);
   SetIndexBuffer(7, gda_164);
   SetIndexLabel(0, "Plot0");
   SetIndexLabel(1, "Plot1");
   SetIndexLabel(2, "Plot2");
   SetIndexLabel(3, "Plot3");
   ArrayResize(gda_172, gi_168);
   ArrayResize(gda_176, gi_168);
   ArrayResize(gda_180, gi_168);
   ArrayResize(gda_184, gi_168);
   ArraySetAsSeries(gda_172, TRUE);
   ArraySetAsSeries(gda_176, TRUE);
   ArraySetAsSeries(gda_180, TRUE);
   ArraySetAsSeries(gda_184, TRUE);
   ArraySetAsSeries(gda_156, TRUE);
   ArraySetAsSeries(gda_160, TRUE);
   ArrayResize(gda_156, Bars);
   ArrayResize(gda_160, Bars);
   gi_188 = TRUE;
   return (0);
}

int start() {
   string ls_0;
   double ld_32;
   int li_40;
   int li_44;
   int li_48;
   double ld_52;
   double ld_60;
   double ld_68;

   int counted_bars = IndicatorCounted();
   if (counted_bars < 0) return (-1);
   if (counted_bars > 0) counted_bars--;
   if (counted_bars > 0) counted_bars--;
   int not_counted_bars = Bars - counted_bars;
   not_counted_bars = MathMax(gi_168, Bars - counted_bars);

   bool li_28 = FALSE;

   if (gt_192 != Time[0]) li_28 = TRUE;
   gt_192 = Time[0];
   if (li_28) {
      ArrayResize(gda_156, Bars);
      ArrayResize(gda_160, Bars);
      for (int counter = Bars - 1; counter >= 0; counter--) {
         gda_156[counter] = Close[counter] - (Close[counter + 1]);
         gda_160[counter] = MathAbs(Close[counter + 1]);
      }
   } else {
      for (counter = not_counted_bars - 1; counter >= 0; counter--) {
         gda_156[counter] = Close[counter] - (Close[counter + 1]);
         gda_160[counter] = MathAbs(Close[counter + 1]);
      }
   }
   for (counter = not_counted_bars - 1; counter >= 0; counter--) gda_152[counter] = f0_0(Length, 4, 4, gda_156, gda_160, counter);
   for (counter = not_counted_bars - 1; counter >= 0; counter--) {
      gda_164[counter] = iMAOnArray(gda_152, 0, 3, 0, MODE_EMA, counter);
      ld_32 = iMAOnArray(gda_152, 0, 7, 0, MODE_EMA, counter);
      li_40 = 11;
      li_44 = 2;
      li_48 = 11;
      ld_52 = iCustom(NULL, 0, "Kaufman3", li_44, li_44, li_48, gd_104, gd_112, gi_120, 0, counter);
      ld_60 = f0_1(Close, 0, 9, counter);
      ld_68 = ld_60 - ld_52;
      gda_144[counter] = EMPTY_VALUE;
      gda_148[counter] = EMPTY_VALUE;
      if (ld_68 > 0.0) gda_144[counter] = 0;
      if (ld_68 < 0.0) gda_148[counter] = 0;
      gda_128[counter] = EMPTY_VALUE;
      gda_132[counter] = EMPTY_VALUE;
      gda_136[counter] = EMPTY_VALUE;
      gda_140[counter] = EMPTY_VALUE;
      if (gda_152[counter] > 0.0 && gda_152[counter] >= gda_164[counter]) gda_128[counter] = gda_152[counter];
      else {
         if ((gda_152[counter] > 0.0 && gda_152[counter] > ld_32 && gda_152[counter] < gda_164[counter]) || (gda_152[counter] < 0.0 && gda_152[counter] > ld_32)) gda_136[counter] = gda_152[counter];
         else {
            if (gda_152[counter] < 0.0 && gda_152[counter] <= gda_164[counter]) gda_132[counter] = gda_152[counter];
            else
               if ((gda_152[counter] < 0.0 && gda_152[counter] > gda_164[counter] && gda_152[counter] < ld_32) || (gda_152[counter] > 0.0 && gda_152[counter] < gda_164[counter])) gda_140[counter] = gda_152[counter];
         }
      }
   }
   return (0);
}

double f0_0(int ai_0, int ai_4, int ai_8, double ada_12[], double ada_16[], int ai_20) {
   int counted_bars = MathMin(ArraySize(gda_172), ArraySize(ada_12));
   for (int li_28 = counted_bars - 1; li_28 >= 0; li_28--) gda_172[li_28] = iMAOnArray(ada_12, 0, ai_0, 0, MODE_EMA, ai_20 + li_28);
   for (li_28 = counted_bars - 1; li_28 >= 0; li_28--) gda_176[li_28] = iMAOnArray(gda_172, 0, ai_4, 0, MODE_EMA, li_28);
   double ld_32 = 100.0 * iMAOnArray(gda_176, 0, ai_8, 0, MODE_EMA, 0);
   for (li_28 = counted_bars - 1; li_28 >= 0; li_28--) gda_180[li_28] = iMAOnArray(ada_16, 0, ai_0, 0, MODE_EMA, ai_20 + li_28);
   for (li_28 = counted_bars - 1; li_28 >= 0; li_28--) gda_184[li_28] = iMAOnArray(gda_180, 0, ai_4, 0, MODE_EMA, li_28);
   double ld_40 = iMAOnArray(gda_184, 0, ai_8, 0, MODE_EMA, 0);
   if (ld_40 != 0.0) return (ld_32 / ld_40);
   return (0);
}

double f0_1(double ada_0[], int ai_4, int ai_8, int ai_12) {
   if (gi_188) {
      gi_188 = FALSE;
      gi_376 = ai_8;
      if (gi_376 > gi_372) gi_376 = gi_372;
      if (gi_376 < 2) gi_376 = 2;
      ArrayResize(gda_380, MathMax(gi_376, gi_372));
      ArrayResize(gda_384, MathMax(gi_376, gi_372));
   }
   for (int not_counted_bars = 1; not_counted_bars <= gi_376; not_counted_bars++) {
      gda_384[not_counted_bars] = not_counted_bars - 1;
      gda_380[not_counted_bars] = ada_0[ai_12 + not_counted_bars - 1];
   }
   gd_196 = 0;
   gd_204 = 0;
   for (not_counted_bars = 1; not_counted_bars <= gi_376; not_counted_bars++) {
      gd_196 += gda_384[not_counted_bars];
      gd_204 += gda_380[not_counted_bars];
   }
   if (gi_376 != 0) {
      gd_196 /= gi_376;
      gd_204 /= gi_376;
   }
   gd_236 = 0;
   gd_244 = 0;
   gd_252 = 0;
   gd_268 = 0;
   gd_276 = 0;
   gd_284 = 0;
   for (not_counted_bars = 1; not_counted_bars <= gi_376; not_counted_bars++) {
      gd_212 = gda_384[not_counted_bars] - gd_196;
      gd_220 = gda_380[not_counted_bars] - gd_204;
      gd_228 = gda_384[not_counted_bars] * gda_384[not_counted_bars] - gd_196 * gd_196;
      gd_236 += gd_212 * gd_212;
      gd_244 += gd_212 * gd_220;
      gd_252 += gd_220 * gd_220;
      gd_268 += gd_212 * gd_228;
      gd_276 += gd_228 * gd_228;
      gd_284 += gd_220 * gd_228;
   }
   double ld_20 = gd_236 * gd_276 - gd_268 * gd_268;
   if (ld_20 != 0.0) {
      gd_300 = (gd_244 * gd_276 - gd_284 * gd_268) / ld_20;
      gd_308 = (gd_236 * gd_284 - gd_268 * gd_244) / ld_20;
   }
   gd_292 = gd_204 - gd_300 * gd_196 - gd_308 * gd_196 * gd_196;
   return (gd_292 + gd_300 * ai_4 + gd_308 * ai_4 * ai_4);
}