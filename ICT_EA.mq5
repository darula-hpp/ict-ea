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

double W_O = 0.0; //The weekly open
int num_orders;



double getLotSize()
{
   //Compute the Lot Size
   return 0.02;
}

//Check if the Previous candle is bullish
bool isPreviousBullish()
{
   double close = iClose(Symbol(),PERIOD_H1,1);
   double open = iOpen(Symbol(), PERIOD_H1, 1);
   return close - open > 0;
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

   double StopLossLevel=4.5;
   double TakeProfitLevel=StopLossLevel*2;

   /*if(ExtStopLoss>0)
      StopLossLevel=m_symbol.NormalizePrice(m_symbol.Ask()-ExtStopLoss);
   if(ExtTakeProfit>0)
      TakeProfitLevel=m_symbol.NormalizePrice(m_symbol.Ask()+ExtTakeProfit);*/

   double volume=getLotSize();
   if(volume!=0.0)
      m_trade.Buy(volume,NULL,m_symbol.Ask(),StopLossLevel,TakeProfitLevel,trade_comment);
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
   //From 8AM to 6PM
   if(today.hour >= 8 && today.hour <= 18)
   {
      //Trading logic, Both London and NY Session
      Print(W_O);
      if(W_O < bid )
      {
         //Look to go long
         Print("We are going long");
      }
      
      else
      {
         //Look to go short
          Print("We are going short");
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
