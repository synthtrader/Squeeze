//+------------------------------------------------------------------+
//|                                                  SwiftTrader.mq4 |
//|                      Copyright © 2011, SynthTrade Software Corp. |
//|                                            http://synthtrade.biz |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, SynthTrade Software Corp."
#property link      "http://synthtrade.biz"

extern bool AllowTrade = false;
extern bool VisualSL = false;
extern bool VisualTP = false;
extern double Lot = 0.01;
extern int BreakEvenLevel = 10;
extern int BreakEvenProfit = 1;
extern int slippage = 3;
extern int MaxDelta = 10;
extern int numTries = 5;
extern int MagicNumber = 123123123;
extern string OkSound = "ok.wav";
extern string BreakEvenSound = "news.wav";

#define order_target "order_target"
#define stoploss_target "stoploss_target"
#define takeprofit_target "takeprofit_target"

#define buy_mode 1
#define sell_mode -1
#define no_mode 0

int targets_distance = 10;
string messages;
datetime lastBar;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   double price = NormalizeDouble (Ask, Digits);
   double tp = NormalizeDouble (price - targets_distance * Point, Digits);
   double sl = NormalizeDouble (price - 2 * targets_distance * Point, Digits);

   lastBar = Time[0];

   //Если линия цены открытия нет на графике - создаем по цене Ask
   if(ObjectFind(order_target)<0) {
      ObjectCreate(order_target, OBJ_HLINE, 0, 0, price);
      ObjectSet (order_target, OBJPROP_COLOR, DarkTurquoise);
      ObjectSet (order_target, OBJPROP_STYLE, STYLE_DOT);
   }
   //иначе устанавливаем её на уровне Ask
   //else ObjectSet(order_target, OBJPROP_PRICE1, price);

   //линия стоплосса чуть ниже цены открытия
   if(ObjectFind(stoploss_target)<0) {
      ObjectCreate(stoploss_target, OBJ_HLINE, 0, 0, NormalizeDouble (sl, Digits));
      ObjectSet (stoploss_target, OBJPROP_COLOR, Red);
      ObjectSet (stoploss_target, OBJPROP_STYLE, STYLE_DOT);
   }
   //else ObjectSet (stoploss_target, OBJPROP_PRICE1, NormalizeDouble (sl, Digits));

   //линия тейкпрофита чуть выше цены открытия
   if(ObjectFind(takeprofit_target)<0) {
      ObjectCreate(takeprofit_target, OBJ_HLINE, 0, 0, NormalizeDouble (tp, Digits));
      ObjectSet (takeprofit_target, OBJPROP_COLOR, Green);
      ObjectSet (takeprofit_target, OBJPROP_STYLE, STYLE_DOT);
   }
   //else ObjectSet (takeprofit_target, OBJPROP_PRICE1, NormalizeDouble (tp, Digits));

   
   
//----

   if (Digits == 3 || Digits == 5) {
      BreakEvenLevel *= 10;
      BreakEvenProfit *= 10;
      slippage *= 10;
      MaxDelta *= 10;
      targets_distance *= 10;
   }

   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   if(ObjectFind(order_target)>0) {
      ObjectDelete(order_target);
   }
   if(ObjectFind(stoploss_target)>0) {
      ObjectDelete(stoploss_target);
   }
   if(ObjectFind(takeprofit_target)>0) {
      ObjectDelete(takeprofit_target);
   }
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
   int trade_mode = no_mode;
   int sl_points, tp_points, result;
   bool onNewBar = false;
   
   messages = "\n";
   if (AllowTrade) {
      addMessage ("Trade: ON");
   }
   else addMessage ("Trade: OFF");

   if (VisualSL) {
      addMessage ("VisualSL: ON");
   }
   else addMessage ("VisualSL: OFF");

   if (VisualTP) {
      addMessage ("VisualTP: ON");
   }
   else addMessage ("VisualTP: OFF");
   
   addMessage ("Lot: " + DoubleToStr (Lot, 2));
   addMessage ("BreakEven: " + BreakEvenLevel);
   
   //значения уровней по линиям
   double screenprice = ObjectGet(order_target, OBJPROP_PRICE1);
   double sl_price = ObjectGet(stoploss_target, OBJPROP_PRICE1);
   double tp_price = ObjectGet(takeprofit_target, OBJPROP_PRICE1);

   //определяем сетап (если таковой есть в наличии)   
   if (tp_price > screenprice && screenprice > sl_price) {
      addMessage ("Setup: Buy mode");
      trade_mode = buy_mode;
   }
   else {
      if (tp_price < screenprice && screenprice < sl_price) {
         addMessage ("Setup: Sell mode");
         trade_mode = sell_mode;
      }
      else addMessage ("Setup: No setup found");
   }
   
   //вывод результата на экран
   if (trade_mode == buy_mode) {
      sl_points = (screenprice - sl_price) / Point;
      tp_points = (tp_price - screenprice) / Point;
      addMessage ("StopLoss: " + sl_points + " points");
      addMessage ("TakeProfit: " + tp_points + " points");
   }
   
   //и то же самое для продаж
   if (trade_mode == sell_mode) {
      sl_points = (sl_price - screenprice) / Point;
      tp_points = (screenprice - tp_price) / Point;
      addMessage ("StopLoss: " + sl_points + " points");
      addMessage ("TakeProfit: " + tp_points + " points");
   }
//----
   //устанавливаем флаг, если открылся новый бар
   if (Time[0] > lastBar) {
      onNewBar = true;
      lastBar = Time[0];
   }

   //открываемся (если нужно) только на новом баре!!!
   if (onNewBar) {
      //если торговля разрешена
      if (AllowTrade) {
         //если сетап на покупку
         if (trade_mode == buy_mode) {
            //проверка условий: предыдущий бар закрылся ниже линии покупки, последний закрылся выше
            if (Close[1] > screenprice && Close[2] < screenprice) {
               //Alert ("Wanna buy!!!");
               result = myOrderSend (OP_BUY, Ask, sl_price, tp_price, Green);
               if (result > 0) PlaySound (OkSound);
               AllowTrade = false;
            }
         } //if (trade_mode == buy_mode) ...
         //если сетап на продажу
         if (trade_mode == sell_mode) {
            //проверка условий: предыдущий бар закрылся выше линии продажи, последний закрылся уже ниже
            if (Close[1] < screenprice && Close[2] > screenprice) {
               //Alert ("Wanna sell!!!");
               result = myOrderSend (OP_SELL, Bid, sl_price, tp_price, Red);
               AllowTrade = false;
            }
         } //if (trade_mode == sell_mode) ...
      } //if (AllowTrade) ...
   } //if (onNewBar) ...

   //поиск открытых ордеров
   int total = OrdersTotal();
   
   for(int i = 0; i < total; i++) {
      if (OrderSelect (i, SELECT_BY_POS, MODE_TRADES) == false) continue;
      if (OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() != Symbol()) continue;
      //перевод в безубыток, если нужно
      checkBreakEven (OrderTicket());
   }

   if (VisualSL) checkSL();
   if (VisualTP) checkTP();

   Comment (messages);
   return(0);
  }
//+------------------------------------------------------------------+

//проверить достигнут ли уровень безубытка
int checkBreakEven (int ticket)
{
   if (OrderSelect (ticket, SELECT_BY_TICKET) == false) return (-1);
   
   if (OrderType() == OP_BUY) {
      if ((OrderStopLoss() < OrderOpenPrice()) &&
         (Bid - OrderOpenPrice() >= BreakEvenLevel * Point)) {
         modifySL (ticket, OrderOpenPrice() + BreakEvenProfit * Point);
      }
   }

   if (OrderType() == OP_SELL) {
      if ((OrderStopLoss() > OrderOpenPrice()) &&
         (OrderOpenPrice() - Ask >= BreakEvenLevel * Point)) {
         modifySL (ticket, OrderOpenPrice() - BreakEvenProfit * Point);
      }
   }
}

void checkSL()
{
   int total = OrdersTotal();
   double sl_price = NormalizeDouble (ObjectGet(stoploss_target, OBJPROP_PRICE1), Digits);
   
   for(int i = 0; i < total; i++) {
      if (OrderSelect (i, SELECT_BY_POS, MODE_TRADES) == false) continue;
      if (OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() != Symbol()) continue;

      if (sl_price != OrderStopLoss()) {
         modifySL (OrderTicket(), sl_price);
      }
   }
}

void checkTP()
{
   int total = OrdersTotal();
   double tp_price = NormalizeDouble (ObjectGet(takeprofit_target, OBJPROP_PRICE1), Digits);
   
   for(int i = 0; i < total; i++) {
      if (OrderSelect (i, SELECT_BY_POS, MODE_TRADES) == false) continue;
      if (OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() != Symbol()) continue;

      if (tp_price != OrderTakeProfit()) {
         modifyTP (OrderTicket(), tp_price);
      }
   }
}

//передвинуть стоп
int modifySL (int ticket, double sl)
{
   if (OrderSelect (ticket, SELECT_BY_TICKET) == false) return (-1);
 
   bool result;  
   for (int i = 0; i < numTries; i++) {
      result = OrderModify (ticket, OrderOpenPrice(), NormalizeDouble (sl, Digits), OrderTakeProfit(), 0, 0);
      if (!result) {
         Print ("Order ModifySL error #", GetLastError());
      }
      else {
         if (BreakEvenSound != "") PlaySound (BreakEvenSound);
         return (ticket);
      }
   }
}

//передвинуть профитстоп
int modifyTP (int ticket, double tp)
{
   if (OrderSelect (ticket, SELECT_BY_TICKET) == false) return (-1);
 
   bool result;  
   for (int i = 0; i < numTries; i++) {
      result = OrderModify (ticket, OrderOpenPrice(), OrderStopLoss(), NormalizeDouble (tp, Digits), 0, 0);
      if (!result) {
         Print ("Order ModifyTP error #", GetLastError());
      }
      else {
         if (BreakEvenSound != "") PlaySound (BreakEvenSound);
         return (ticket);
      }
   }
}


//открытие ордера - несколько попыток с учетом реквот и максимального отклонения от начальной цены
int myOrderSend (int cmd, double price, double sl, double tp, int icolor)
{
   int ticket, error;
   double current_price = price;
   
   for (int i = 0; i < numTries; i++) {
      ticket = OrderSend(Symbol(), cmd, Lot, NormalizeDouble (current_price, Digits), slippage, NormalizeDouble (sl, Digits), NormalizeDouble (tp, Digits), "SwiftTrader", MagicNumber, 0, icolor);
      if (ticket < 0) {
         error = GetLastError();
         Print("OrderSend failed with error #", error);
         // if (ERR_INVALID_PRICE || ERR_REQUOTE || ERR_PRICE_CHANGED)
         if (error == 129 || error == 138 || error == 135) {
            RefreshRates();
            //для покупок
            if (cmd == OP_BUY) {
               if ((MathAbs (Ask - price) / Point) < MaxDelta) {
                  current_price = Ask;
               }
               else {
                  Print ("Error! Buy Price is bigger than allowed by MaxDelta!");
                  return (-1);
               }
            }
            //для продаж
            else {
               if ((MathAbs (price - Bid) / Point) < MaxDelta) {  
                  current_price = Bid;
               }
               else {
                  Print ("Error! Sell Price is lower than allowed by MaxDelta!");
                  return (-1);
               }                  
            } //else ...
         } //if (error) ...
      } //if (ticket < 0) ...
      else {
         if (OkSound != "") PlaySound (OkSound);
         return (ticket);
      }
   } //for (...)
} //int myOrderSend (...)

void addMessage (string line) 
{
   messages = messages + "   " + line + "\n";
}

