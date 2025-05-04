//+------------------------------------------------------------------+
//|                                                      CustomEA.mq5|
//|             Greed + Fear + Intuition Strategy EA                |
//+------------------------------------------------------------------+
#property copyright "ChatGPT"
#property link      "https://openai.com"
#property version   "1.00"
#property strict

input double lotSize = 0.1;
input int    slippage = 3;
input double stopLoss = 100; // in points
input double takeProfit = 200; // in points
input ENUM_TIMEFRAMES Timeframe = PERIOD_H1;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   Print("Greed + Fear + Intuition EA initialized.");
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(isGreedHigh() && isFearHigh() && isIntuitionHighBullish())
     {
      if(PositionSelect(Symbol()) == false)
        {
         tradeBuy();
        }
     }
   else if(isGreedHigh() && isFearHigh() && isIntuitionHighBearish())
     {
      if(PositionSelect(Symbol()) == false)
        {
         tradeSell();
        }
     }
  }

//+------------------------------------------------------------------+
//| Conditions                                                       |
//+------------------------------------------------------------------+
bool isGreedHigh()
  {
   int rsiPeriod = 14;
   int rsiHandle = iRSI(Symbol(), Timeframe, rsiPeriod, PRICE_CLOSE);
   if(rsiHandle == INVALID_HANDLE)
     {
      Print("Failed to create RSI handle");
      return false;
     }

   double rsiBuffer[];
   if(CopyBuffer(rsiHandle, 0, 0, 1, rsiBuffer) <= 0)
     {
      Print("Failed to copy RSI data. Error: ", GetLastError());
      return false;
     }

   return rsiBuffer[0] > 70;
  }

bool isFearHigh()
  {
   int rsiPeriod = 14;
   int rsiHandle = iRSI(Symbol(), Timeframe, rsiPeriod, PRICE_CLOSE);
   if(rsiHandle == INVALID_HANDLE)
     {
      Print("Failed to create RSI handle");
      return false;
     }

   double rsiBuffer[];
   if(CopyBuffer(rsiHandle, 0, 0, 1, rsiBuffer) <= 0)
     {
      Print("Failed to copy RSI data. Error: ", GetLastError());
      return false;
     }

   return rsiBuffer[0] < 30;
  }

bool isIntuitionHighBullish()
  {
   double macdCurrent, signalCurrent, histCurrent;
   double macdPrevious, signalPrevious, histPrevious;

   if(!iMACD(Symbol(), Timeframe, 12, 26, 9, PRICE_CLOSE, macdCurrent, signalCurrent, histCurrent, 0)) return false;
   if(!iMACD(Symbol(), Timeframe, 12, 26, 9, PRICE_CLOSE, macdPrevious, signalPrevious, histPrevious, 1)) return false;

   return (histPrevious < 0 && histCurrent > 0);
  }

bool isIntuitionHighBearish()
  {
   double macdCurrent, signalCurrent, histCurrent;
   double macdPrevious, signalPrevious, histPrevious;

   if(!iMACD(Symbol(), Timeframe, 12, 26, 9, PRICE_CLOSE, macdCurrent, signalCurrent, histCurrent, 0)) return false;
   if(!iMACD(Symbol(), Timeframe, 12, 26, 9, PRICE_CLOSE, macdPrevious, signalPrevious, histPrevious, 1)) return false;

   return (histPrevious > 0 && histCurrent < 0);
  }

//+------------------------------------------------------------------+
//| Trade functions                                                  |
//+------------------------------------------------------------------+
void tradeBuy()
  {
   double price = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
   double sl = price - stopLoss * _Point;
   double tp = price + takeProfit * _Point;
   if(OrderSend(Symbol(), OP_BUY, lotSize, price, slippage, sl, tp, "GreedBuy", 0, 0, clrGreen) < 0)
     {
      Print("Buy order failed: ", GetLastError());
     }
   else
      Print("Buy order placed");
  }

void tradeSell()
  {
   double price = SymbolInfoDouble(Symbol(), SYMBOL_BID);
   double sl = price + stopLoss * _Point;
   double tp = price - takeProfit * _Point;
   if(OrderSend(Symbol(), OP_SELL, lotSize, price, slippage, sl, tp, "FearSell", 0, 0, clrRed) < 0)
     {
      Print("Sell order failed: ", GetLastError());
     }
   else
      Print("Sell order placed");
  }
