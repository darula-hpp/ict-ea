//+------------------------------------------------------------------+
//|                                                       ICT_EA.mq5 |
//|                                                 Olebogeng Mbedzi |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\SymbolInfo.mqh>  

double account_balance = ACCOUNT_BALANCE;
double account_equity = ACCOUNT_EQUITY;
datetime time;
datetime current_time;
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
int SHIFT_BACK_START = 10; //How many hours to shift back
int SHIFT_DURATION = 15; //After @SHIFT_BACK_START, how many hours more to shift back

double W_O = 0.0; //The weekly open
int num_orders;



double getLotSize()
{
   //Compute the Lot Size
   return 0.02;
}

//Get the lowest price in the past 10 hours + 15 Hours
//The function is used for long Positions
double getLowestPrevPrice()
{
   double lowest = 1000000; //hopefully gold will never reach this price LOL
   double close = 0.0;
   for(int i = SHIFT_BACK_START; i < SHIFT_BACK_START + SHIFT_DURATION; i++)
   {
      //We care about the close of bearish candles
      if(lowest > iClose(Symbol(),PERIOD_H1,i))
      {
         lowest =  iClose(Symbol(),PERIOD_H1,i);
      }
      
   }
   
   return lowest;
}

double getHighestPrevPrice()
{
   double highest = 0.0; //
   double close = 0.0;
   for(int i = SHIFT_BACK_START; i < SHIFT_BACK_START + SHIFT_DURATION; i++)
   {
      //We care about the close of bearish candles
      if(highest < iClose(Symbol(),PERIOD_H1,i))
      {
         highest =  iClose(Symbol(),PERIOD_H1,i);
      }
      
   }
   
   return highest;
}

//Check if the Previous candle is bullish
bool isPreviousBullish()
{
   double close = iClose(Symbol(),PERIOD_H1,1);
   double open = iOpen(Symbol(), PERIOD_H1, 1);
   return (close - open) > 0;
}

//+------------------------------------------------------------------+
string DayOfWeek(int dow){
   string day[] = {"Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"};
   return day[dow];
}

//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool refreshRates()
{
//--- refresh rates
if(!m_symbol.RefreshRates())
   return(false);
//--- protection against the return value of "zero"
if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
   return(false);
//---
return(true);
}

void buy()
  {
   string trade_comment = "We buying";
   if(!refreshRates())
      return;

   double StopLossLevel=0.0;
   double TakeProfitLevel=StopLossLevel*2;
   StopLossLevel=m_symbol.NormalizePrice(m_symbol.Ask()-4.5);
      
   TakeProfitLevel=m_symbol.NormalizePrice(m_symbol.Ask()+(4.5*2));

   double volume=getLotSize();
   if(volume!=0.0)
      m_trade.Buy(volume,NULL,m_symbol.Ask(),StopLossLevel,TakeProfitLevel,trade_comment);
  }
  
  void sell()
  {
   string trade_comment = "We Selling";
   if(!refreshRates())
      return;

   double StopLossLevel=0.0;
   double TakeProfitLevel=0.0;

   StopLossLevel=m_symbol.NormalizePrice(m_symbol.Bid()+4.5);
   TakeProfitLevel=m_symbol.NormalizePrice(m_symbol.Bid()-(4.5*2));
//---
   double volume= getLotSize();
   if(volume!=0.0)
   {
      m_trade.Sell(volume,NULL,m_symbol.Bid(),StopLossLevel,TakeProfitLevel,trade_comment);
   }
  }

int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   CAccountInfo account;
   Print("ICT");
   ENUM_ACCOUNT_TRADE_MODE account_type=account.TradeMode();
   if(account_type == ACCOUNT_TRADE_MODE_REAL)
   {
      Print("Trading on a real account");
   }
   else
   {
      Print("Trading on a Demo account.");
   }
   time = TimeLocal();
   
    m_symbol.Name(Symbol());                  // sets symbol name
   
   
  
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
//Bid for long and ask for short positions
void OnTick()
  {
//---
   //Open positions
   //Close positions
   //Modify positions
   current_time = TimeLocal();
   num_orders =  OrdersTotal();
   double ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), Digits());
   double bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), Digits());
   
   
   //---
   MqlDateTime today;
   TimeCurrent(today);
   string day_of_week = DayOfWeek(today.day_of_week);
   if(day_of_week == "Monday")
   {
      //Monday
      if(today.hour = 1)
      {
         W_O = iOpen(Symbol(), PERIOD_H1, 1);  //We need a fool proof way of getting the W_O
      }
      

   }
   
   //Only trade if theres no orders open
   if(day_of_week == "Monday" || day_of_week == "Friday")
   {
   return;
   }
   if(num_orders == 0)
   {
   //From 8AM to 6PM
      if(today.hour >= 1 && today.hour <= 18)
      {
         //Trading logic, Both London and NY Session
         //Look to go long
         if(W_O < bid )
         {
            //Only look to buy when the previous is bearish
            if(!isPreviousBullish())
            {
               double lowest = getLowestPrevPrice();
               //get the previous bearish candle Open
               double open = iOpen(Symbol(), PERIOD_H1, 1);
               double close = iClose(Symbol(), PERIOD_H1, 1);
               //If the current candle is greater or equal to the previous candle open, prepare to enter
               if(bid >= open)
               {
                  
                  //Check if the previous candle close is greater than the lowest of the previous days candles
                  if(lowest >= close) //if the lowest candle is greater than the prev close, we go long
                  {
                  //Turtlesoup buy
                     printf("We are going long %lf", lowest);
                     buy();
                  }
               }
            
            }
            
         }
         
         else
         {
            
            if(isPreviousBullish())
            {
               Print("Bearish scenario");
               double highest = getHighestPrevPrice();
               //get the previous bearish candle Open
               double open = iOpen(Symbol(), PERIOD_H1, 1);
               double close = iClose(Symbol(), PERIOD_H1, 1);
               //If the current candle is less or equal to the previous candle open, prepare to enter
               if(ask <= open)
               { 
                  if(highest <= close ) //if the close price is higher than the highest previous//we go short
                  {
                     printf("We are going short %lf", highest);
                     sell();
                  }
               }
            }
         }
      }
   }



  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   
  }
//+------------------------------------------------------------------+
