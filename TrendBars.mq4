#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Lime
#property indicator_color2 Red
#property indicator_color3 Lime
#property indicator_color4 Red
#property indicator_color5 Lime
#property indicator_color6 Red

#define buy_signal 1
#define sell_signal -1
#define undefined_signal 0

extern bool AlertOn = true;

extern int Length1 = 13;
extern int Length2 = 34;
extern int Length3 = 89;

//уровни точек
extern int Position1 = 35;
extern int Position2 = 0;
extern int Position3 = -35;

//indicator buffers
//dot1
double dot1_a[]; //green dot
double dot1_b[]; //red dot
//dot2
double dot2_a[];
double dot2_b[];
//dot3
double dot3_a[];
double dot3_b[];

//non indicator buffers
double convdiver1[];
double convdiver2[];
double convdiver3[];


bool gi_152 = TRUE;
datetime lastBarTime;

int init() {
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexArrow(0, 159);
   SetIndexBuffer(0, dot1_a);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(1, 159);
   SetIndexBuffer(1, dot1_b);
   SetIndexStyle(2, DRAW_ARROW);
   SetIndexArrow(2, 159);
   SetIndexBuffer(2, dot2_a);
   SetIndexStyle(3, DRAW_ARROW);
   SetIndexArrow(3, 159);
   SetIndexBuffer(3, dot2_b);
   SetIndexStyle(4, DRAW_ARROW);
   SetIndexArrow(4, 159);
   SetIndexBuffer(4, dot3_a);
   SetIndexStyle(5, DRAW_ARROW);
   SetIndexArrow(5, 159);
   SetIndexBuffer(5, dot3_b);
   ArraySetAsSeries(convdiver1, TRUE);
   ArraySetAsSeries(convdiver2, TRUE);
   ArraySetAsSeries(convdiver3, TRUE);
   return (0);
}

int deinit() {
   return (0);
}

int start() {
   string ls_0;
   string debug_msg = "";
   int period_64;

   double current_ima_convdiver1;
   double current_ima_convdiver2;
   double current_ima_convdiver3;

   double lastbar_ima_convdiver1;
   double lastbar_ima_convdiver2;
   double lastbar_ima_convdiver3;

   int last_signal;
   int current_signal;
   
   int countedBars = myIndicatorCounted();
   if (countedBars < 0) return (-1);
   if (countedBars > 0) countedBars--;
   int notCountedBars = Bars - countedBars;
   bool newBarFlag = FALSE;
   if (lastBarTime != Time[0]) newBarFlag = TRUE;
   lastBarTime = Time[0];

/* только на новом баре */
   if (newBarFlag) {
      //увеличиваем массивы, чтобы поместились новые бары
      ArrayResize(convdiver1, Bars);
      ArrayResize(convdiver2, Bars);
      ArrayResize(convdiver3, Bars);
      
      //передвигаем старые данные в конец...
      if (countedBars > 0) {
         for (int icounter = Bars - 1; icounter > 0; icounter--) {
            convdiver1[icounter] = convdiver1[icounter - 1];
            convdiver2[icounter] = convdiver2[icounter - 1];
            convdiver3[icounter] = convdiver3[icounter - 1];
         }
      }
      //только если в режиме оповещения об изменениях в рынке
      if (AlertOn) {
         //получить текущее состояние
         current_signal = getSignal (dot1_a[1], dot2_a[1], dot3_a[1]);
         last_signal = getSignal (dot1_a[2], dot2_a[2], dot3_a[2]);
         //и если все точки одного цвета
         if (current_signal != undefined_signal) {
            //смотрим изменился ли сигнал по сравнению с предыдущим
            if (current_signal != last_signal) {
               Alert (Symbol() + ": check trend bars!!!");
            }
         }
         Print ("Current = ", current_signal, ", Last = ", last_signal);
      } //if (AlertOn) ...
   }

   //вычисления для периода 1

   double roundedHalfPeriod = 0;
   double roundedSqrtLength = 0;
   
   //вычисляем полупериод
   double halfPeriod = Length1 / 2.0;

   //1.5 округляем к 2, 1.3 округляем к 1
   if (MathCeil(halfPeriod) - halfPeriod <= 0.5) roundedHalfPeriod = MathCeil(halfPeriod);
   else roundedHalfPeriod = MathFloor(halfPeriod);
   
   //берем квадратный корень от периода
   double sqrtLength1 = MathSqrt(Length1);

   //откругляем так же...
   if (MathCeil(sqrtLength1) - sqrtLength1 <= 0.5) roundedSqrtLength = MathCeil(sqrtLength1);
   else roundedSqrtLength = MathFloor(sqrtLength1);
   
   //convdiver1 - развал-схождение двух средних (двойная от периода деленного на два - средняя от полного периода Length1)
   for (icounter = notCountedBars - 1; icounter >= 0; icounter--) {
      period_64 = roundedHalfPeriod;
      current_ima_convdiver1 = 2 * iMA(NULL, 0, period_64, 0, MODE_LWMA, PRICE_CLOSE, icounter);
      current_ima_convdiver2 = iMA(NULL, 0, Length1, 0, MODE_LWMA, PRICE_CLOSE, icounter);
      convdiver1[icounter] = current_ima_convdiver1 - current_ima_convdiver2;
   }

   //сохраняем округленный квадратный корень от периода1
   int roundedSqrtLength1 = roundedSqrtLength;

   //вычисления для периода 2

   roundedHalfPeriod = 0;
   roundedSqrtLength = 0;

   //берем полупериод от периода2
   halfPeriod = Length2 / 2;
   
   //округляем
   if (MathCeil(halfPeriod) - halfPeriod <= 0.5) roundedHalfPeriod = MathCeil(halfPeriod);
   else roundedHalfPeriod = MathFloor(halfPeriod);
   
   //квадратный корень от периода2
   sqrtLength1 = MathSqrt(Length2);
   
   //округляем
   if (MathCeil(sqrtLength1) - sqrtLength1 <= 0.5) roundedSqrtLength = MathCeil(sqrtLength1);
   else roundedSqrtLength = MathFloor(sqrtLength1);

   period_64 = roundedHalfPeriod;

   //convdiver2 - развал-схождение двух средних (двойная от периода деленного на два - средняя от полного периода Length2)
   for (icounter = notCountedBars - 1; icounter >= 0; icounter--) {
      current_ima_convdiver1 = 2 * iMA(NULL, 0, period_64, 0, MODE_LWMA, PRICE_CLOSE, icounter);
      current_ima_convdiver2 = iMA(NULL, 0, Length2, 0, MODE_LWMA, PRICE_CLOSE, icounter);
      convdiver2[icounter] = current_ima_convdiver1 - current_ima_convdiver2;
   }

   //сохраняем округленный квадратный корень от периода2
   int roundedSqrtLength2 = roundedSqrtLength;

   //вычисления для периода 3

   roundedHalfPeriod = 0;
   roundedSqrtLength = 0;
   
   //получаем полупериод
   halfPeriod = Length3 / 2;
   
   //округляем
   if (MathCeil(halfPeriod) - halfPeriod <= 0.5) roundedHalfPeriod = MathCeil(halfPeriod);
   else roundedHalfPeriod = MathFloor(halfPeriod);
   
   //берем квадратный корень от периода 3
   sqrtLength1 = MathSqrt(Length3);
   
   //тоже округляем
   if (MathCeil(sqrtLength1) - sqrtLength1 <= 0.5) roundedSqrtLength = MathCeil(sqrtLength1);
   else roundedSqrtLength = MathFloor(sqrtLength1);
   
   period_64 = roundedHalfPeriod;
   
   //convdiver3 - развал-схождение двух средних (двойная от периода деленного на два - средняя от полного периода Length3)   
   for (icounter = notCountedBars - 1; icounter >= 0; icounter--) {
      current_ima_convdiver1 = 2 * iMA(NULL, 0, period_64, 0, MODE_LWMA, PRICE_CLOSE, icounter);
      current_ima_convdiver2 = iMA(NULL, 0, Length3, 0, MODE_LWMA, PRICE_CLOSE, icounter);
      convdiver3[icounter] = current_ima_convdiver1 - current_ima_convdiver2;
   }

   //сохраняем округленный квадратный корень от периода3
   int roundedSqrtLength3 = roundedSqrtLength;


   //самое интересное :)
   for (icounter = notCountedBars - 1; icounter >= 0; icounter--) {
      if (countedBars == 0) {
         dot1_a[icounter] = EMPTY_VALUE;
         dot1_b[icounter] = EMPTY_VALUE;
         dot2_a[icounter] = EMPTY_VALUE;
         dot2_b[icounter] = EMPTY_VALUE;
         dot3_a[icounter] = EMPTY_VALUE;
         dot3_b[icounter] = EMPTY_VALUE;
      }

      //сглаживаем скользящей с периодом равному квадратному корню исходного периода полученный массив развал-схождения
      //для текущего бара
      current_ima_convdiver1 = iMAOnArray(convdiver1, 0, roundedSqrtLength1, 0, MODE_LWMA, icounter);
      current_ima_convdiver2 = iMAOnArray(convdiver2, 0, roundedSqrtLength2, 0, MODE_LWMA, icounter);
      current_ima_convdiver3 = iMAOnArray(convdiver3, 0, roundedSqrtLength3, 0, MODE_LWMA, icounter);

      //для предыдущего бара
      lastbar_ima_convdiver1 = iMAOnArray(convdiver1, 0, roundedSqrtLength1, 0, MODE_LWMA, icounter + 1);
      lastbar_ima_convdiver2 = iMAOnArray(convdiver2, 0, roundedSqrtLength2, 0, MODE_LWMA, icounter + 1);
      lastbar_ima_convdiver3 = iMAOnArray(convdiver3, 0, roundedSqrtLength3, 0, MODE_LWMA, icounter + 1);

      //рисуем три точки индикатора, ради которых всё и затевалось
      setDot(dot1_a, dot1_b, icounter, current_ima_convdiver1, lastbar_ima_convdiver1, Position1);
      setDot(dot2_a, dot2_b, icounter, current_ima_convdiver2, lastbar_ima_convdiver2, Position2);
      setDot(dot3_a, dot3_b, icounter, current_ima_convdiver3, lastbar_ima_convdiver3, Position3);
   }
   return (0);
}

//получить сигнал - если все точки зеленые - к покупке, если красные - к продаже
int getSignal (double dot1, double dot2, double dot3) 
{
   if (dot1 == EMPTY_VALUE && dot2 == EMPTY_VALUE && dot3 == EMPTY_VALUE) {
      return (sell_signal);
   }
   if (dot1 != EMPTY_VALUE && dot2 != EMPTY_VALUE && dot3 != EMPTY_VALUE) {
      return (buy_signal);
   }
   return (undefined_signal);
}

void setDot (double &dot_a[], double &dot_b[], int ibar, double current_value, double last_value, double position) {
   if (current_value > last_value) {
      dot_a[ibar] = position;
      return;
   }
   dot_b[ibar] = position;
}

int myIndicatorCounted()
{
   static int lastCount = 0;
   int count = IndicatorCounted();
   if (count > lastCount) {
      lastCount = count;
      return (count);
   }
   return (lastCount);
}

