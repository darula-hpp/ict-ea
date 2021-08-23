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
#include <MovingAverages.mqh>


#property indicator_separate_window
//---------------------------------------------------------------------
#property indicator_applied_price       PRICE_CLOSE
#property indicator_minimum             -1.4
#property indicator_maximum             +1.4
//---------------------------------------------------------------------
#property indicator_buffers             1
#property indicator_plots               1
//---------------------------------------------------------------------
#property indicator_type1               DRAW_HISTOGRAM
#property indicator_color1              Black
#property indicator_width1              2
input int   MAPeriod = 50;
double TrendBuffer[];

//Trend
int LOOK_BACK = 48; //90 hours
int MA1;
int MA2;


double account_balance = ACCOUNT_BALANCE;
double account_equity = ACCOUNT_EQUITY;
datetime time;
datetime current_time;
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
int SHIFT_BACK_START = 10; //How many hours to shift back
int SHIFT_DURATION = 96; //After @SHIFT_BACK_START, how many hours more to shift back 10 15 24
int            handle_iRSI;                  // variable for storing the handle of the iRSI indicator
input int      RSIperiod         = 14;       // RSIperiod
double stop_loss_level = 0.0; //The stop_loss_level
double stop_loss_pips = 4.5; //The stop_loss_points;

double W_O = 0.0; //The weekly open
int num_orders;



double getLotSize()
{
   //Compute the Lot Size
   return 0.12;
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
   return close > open;
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

//The multiplier of the StopLoss
double getMultiplier(double daily_average)
{
   if(daily_average >= 10)
      return 4;
   return 3;
}

void buy(double daily_average)
  {
   if(!refreshRates())
      return;
      
   double prev_low = iLow(Symbol(),PERIOD_H1,1);
   double sl = m_symbol.Ask() - prev_low;
   string trade_comment = "We buying and sl " + sl;    

   double StopLossLevel=0.0;
   double TakeProfitLevel=StopLossLevel*2;
   StopLossLevel=m_symbol.NormalizePrice(m_symbol.Ask()-4.5);
      
   TakeProfitLevel=m_symbol.NormalizePrice(m_symbol.Ask()+(stop_loss_pips * getMultiplier(daily_average)));

   double volume=getLotSize();
   if(volume!=0.0)
      m_trade.Buy(volume,NULL,m_symbol.Ask(),StopLossLevel,TakeProfitLevel,trade_comment);
  }
  
  void sell(double daily_average)
  {
   if(!refreshRates())
      return;
      
   double prev_high = iHigh(Symbol(),PERIOD_H1,1);
   double sl = prev_high - m_symbol.Bid();
   string trade_comment = "We selling and sl " + sl;   

   double StopLossLevel=0.0;
   double TakeProfitLevel=0.0;

   StopLossLevel=m_symbol.NormalizePrice(m_symbol.Bid()+4.5);
   TakeProfitLevel=m_symbol.NormalizePrice(m_symbol.Bid()-(stop_loss_pips * getMultiplier(daily_average)));
//---
   double volume= getLotSize();
   if(volume!=0.0)
   {
      m_trade.Sell(volume,NULL,m_symbol.Bid(),StopLossLevel,TakeProfitLevel,trade_comment);
   }
  }
  
  //The average of the previous 5 days
  double getLast5daysDailyAverage()
  {
   double total = 0.0;
   double close = 0.0;
   double open = 0.0;
   for(int i = 1; i < 6; i++)
   {
      //We care about the close of bearish candles
      close = iClose(Symbol(),PERIOD_D1,i);
      open = iOpen(Symbol(),PERIOD_D1,i);
      total += MathAbs(close - open);
      
   }
   
   return total/5;
   
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
     
     SetIndexBuffer( 0, TrendBuffer, INDICATOR_DATA );
  PlotIndexSetInteger( 0, PLOT_DRAW_BEGIN, MAPeriod );
    MA1 = iMA(Symbol(), PERIOD_H1, 5, 0, MODE_SMA, MODE_CLOSE);
    MA2 = iMA(Symbol(), PERIOD_H1, 30, 0, MODE_SMA, MODE_CLOSE);
   
   
  
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
   int num_positions =  PositionsTotal();
   double ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), Digits());
   double bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), Digits());
   double last_5_da = getLast5daysDailyAverage();
   double current_range = MathAbs(iOpen(Symbol(), PERIOD_H1, 1) - ask);
   
  // printf("Last 5 days %lf", last_5_da);
   
   //---
   MqlDateTime today;
   TimeCurrent(today);
   string day_of_week = DayOfWeek(today.day_of_week);
   if(day_of_week == "Monday")
   {
      //Monday
      today.hour = 1;
      W_O = iOpen(Symbol(), PERIOD_H1, 1);  //We need a fool proof way of getting the W_O
      /*if(today.hour == 1)
      {
         W_O = iOpen(Symbol(), PERIOD_H1, 1);  //We need a fool proof way of getting the W_O
      }*/
      

   }
   
   //Only trade if theres no orders open
   if(num_positions == 0)
   {
   //From 1PMM to 6PM
      if(today.hour >= 0 /*&& today.hour <= 23*/)
      //if(today.hour >= 0 /*&& today.hour <= 23*/)
      {
         if(current_range > (0.8 * last_5_da)) //if the current range is greator than 80% the last 5 daily range, do not trade
         {
            return;
         }
   
         //Trading logic, Both London and NY Session
         //Look to go long
         if(W_O < bid )
         {
            //Only look to buy when the previous is bearish
            if(!isPreviousBullish())
            {
               double lowest = getLowestPrevPrice();
               //get the previous bearish candle Open
               double prev_open = iOpen(Symbol(), PERIOD_H1, 1);
               double prev_close = iClose(Symbol(), PERIOD_H1, 1);
               double prev_low = iLow(Symbol(), PERIOD_H1, 1);
               double current_open = iOpen(Symbol(), PERIOD_H1, 0);
               
               //if the lowest candle is greater than the prev close, we go long
               if(lowest >= prev_close) //Check if the previous candle close is greater than the lowest of the previous days candles
               {
                  
                  //If the current candle is greater or equal to the previous candle open, prepare to enter
                  if(bid >= prev_open) 
                  {
                  //Turtlesoup buy
                     //if(rsi_1 < 50)
                     if(!tradeOpenedToday())
                     {
                        if(!isBearish())
                        {
                           buy(last_5_da);
                        }
                      }
                  }
               }
            
            }
            
         }
         
         else
         {
            
            if(isPreviousBullish())
            {
               double highest = getHighestPrevPrice();
               //get the previous bearish candle Open
               double open = iOpen(Symbol(), PERIOD_H1, 1);
               double close = iClose(Symbol(), PERIOD_H1, 1);
               double current_open = iOpen(Symbol(), PERIOD_H1, 0);
               double prev_high = iHigh(Symbol(), PERIOD_H1, 1);
              
               if(highest <= close)//$$$$$BAD IN TRENDING CONDITIONSif the close price is higher than the highest previous//we go short
               { 
                  if(ask <= open)  //If the current candle is less or equal to the previous candle open, prepare to enter
                  {
    
                     if(!tradeOpenedToday())
                     {
                        if(!isBullish())
                        {
                           sell(last_5_da);
                        }
                     }
                  }
               }
            }
         }
      }
   }
   modifyStop(ask);



  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+

void modifyStop(double current_price)
{
      int total_positions=PositionsTotal(); // number of open positions   
      double SL = current_price - stop_loss_pips;
      for(int i = 0; i < total_positions; i++)
      {
         string symbol = PositionGetSymbol(i);
         ulong position_ticket = PositionGetInteger(POSITION_TICKET);
         double current_stoploss = PositionGetDouble(POSITION_SL);
         double entry_price = PositionGetDouble(POSITION_PRICE_OPEN);
         double tp = PositionGetDouble(POSITION_TP);
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
         {
            if(current_price >= (entry_price+ stop_loss_pips*2))
            {
               m_trade.PositionModify(position_ticket, entry_price+ stop_loss_pips, tp);
               //Print("Modified Buy Position");
            }
         }
         
         else
         {
            if(current_price <= (entry_price - stop_loss_pips *2))
            {
               m_trade.PositionModify(position_ticket, entry_price - stop_loss_pips, tp);
               //Print("Modified Sell Position");
            }
         }
      }
      
}



bool tradeOpenedToday()
{
   datetime now=TimeCurrent();
   datetime today=(now/86400)*86400;
   HistorySelect(today,now);
   int deals=HistoryDealsTotal();
   /*if(deals > 3)
   {
      Print("Alreadyy traded");
      return true;
   }*/

   return false;
}

bool isBullish()
{
   double ma_data_1[];
   double ma_data_2[];
   
   ArraySetAsSeries(ma_data_1, true);
   ArraySetAsSeries(ma_data_2, true);
   CopyBuffer(MA1, 0, 0, LOOK_BACK, ma_data_1);
   CopyBuffer(MA2, 0, 0, LOOK_BACK, ma_data_2);
   
   double ma1_datum = 0;
   double ma2_datum = 0;
   
   for(int i = 0; i < LOOK_BACK; i++)
   {
       ma1_datum = ma_data_1[i];
       ma2_datum = ma_data_2[i];
       if(ma2_datum > ma1_datum)
       {
         return false;
       }
      
   }
   
   return true;
   
}

bool isBearish()
{
   double ma_data_1[];
   double ma_data_2[];
   
   ArraySetAsSeries(ma_data_1, true);
   ArraySetAsSeries(ma_data_2, true);
   CopyBuffer(MA1, 0, 0, LOOK_BACK, ma_data_1);
   CopyBuffer(MA2, 0, 0, LOOK_BACK, ma_data_2);
   
   double ma1_datum = 0;
   double ma2_datum = 0;
   
   for(int i = 0; i < LOOK_BACK; i++)
   {
       ma1_datum = ma_data_1[i];
       ma2_datum = ma_data_2[i];
       if(ma2_datum < ma1_datum)
       {
         return false;
       }
      
   }
   
   return true;
}