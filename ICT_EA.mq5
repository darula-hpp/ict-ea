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
   return 0.04;
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

//The multiplier of the StopLoss
double getMultiplier(double daily_average)
{
   if(daily_average >= 10)
      return 4;
   return 3;
}

void buy(double daily_average)
  {
   string trade_comment = "We buying";
   if(!refreshRates())
      return;

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
   string trade_comment = "We Selling";
   if(!refreshRates())
      return;

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
   
   
  
//---
   return(INIT_SUCCEEDED);
  }
  
int OnCalculate(const int _rates_total, 
                const int _prev_calculated,
                const int _begin, 
                const double& _price[ ] )
{
   Print("hey there");
   printf("Rates tota %d", _rates_total);
  int  start, i;

//   If number of bars on the screen is less than averaging period, calculations can't be made:
  if( _rates_total < MAPeriod )
  {
    return( 0 );
  }

//  Determine the initial bar for indicator buffer calculation:
  if( _prev_calculated == 0 )
  {
    start = MAPeriod;
  }
  else
  {
    start = _prev_calculated - 1;
  }

//      Loop of calculating the indicator buffer values:
  for( i = start; i < _rates_total; i++ )
  {
    TrendBuffer[ i ] = TrendDetector( i, _price );
  }

  return( _rates_total );
}

int TrendDetector(int _shift, const double& _price[])
{
  double  current_ma;
  int     trend_direction = 0;

  current_ma = SimpleMA(_shift, MAPeriod, _price);

  if(_price[_shift] > current_ma)
  {
    trend_direction = 1;
  }
  else if(_price[_shift] < current_ma)
  {
    trend_direction = -1;
  }

  return(trend_direction);
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
      /*if(today.hour = 1)
      {
         W_O = iOpen(Symbol(), PERIOD_H1, 1);  //We need a fool proof way of getting the W_O
      }*/
      

   }
   
   //Only trade if theres no orders open
   /*if(day_of_week == "Monday" || day_of_week == "Friday")
   {
   return;
   }*/
   //printf("total orders: %d", num_positions);
   if(num_positions == 0)
   {
   //From 8AM to 6PM
      if(today.hour >= 1 && today.hour <= 18)
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
               double open = iOpen(Symbol(), PERIOD_H1, 1);
               double close = iClose(Symbol(), PERIOD_H1, 1);
               //If the current candle is greater or equal to the previous candle open, prepare to enter
               if(bid >= open)
               {
                  
                  //Check if the previous candle close is greater than the lowest of the previous days candles
                  if(lowest >= close) //if the lowest candle is greater than the prev close, we go long
                  {
                  //Turtlesoup buy
                     //if(rsi_1 < 50)
                     if(!tradeOpenedToday())
                        buy(last_5_da);
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
               //If the current candle is less or equal to the previous candle open, prepare to enter
               if(ask <= open)
               { 
                  if(highest <= close ) //if the close price is higher than the highest previous//we go short
                  {
    
                     //if(rsi_1 > 50)
                     if(!tradeOpenedToday())
                        sell(last_5_da);
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

//+------------------------------------------------------------------+
//| Get value of buffers for the iRSI                                |
//+------------------------------------------------------------------+
double iRSIGet(const int index)
  {
   double RSI[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iRSI array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iRSI,0,index,1,RSI)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iRSI indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(RSI[0]);
  }
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

bool isFalling()
{
   int mv1 = iMA(_Symbol, PERIOD_H1, 20, 0, MODE_EMA, PRICE_CLOSE);
   int mv2 = iMA(_Symbol, PERIOD_H1, 9, 0, MODE_EMA, PRICE_CLOSE);
   return false;
}


bool isRising()
{
   int mv1 = iMA(_Symbol, PERIOD_H1, 20, 0, MODE_EMA, PRICE_CLOSE);
   int mv2 = iMA(_Symbol, PERIOD_H1, 9, 0, MODE_EMA, PRICE_CLOSE);
   double ma1_array[];
   ArraySetAsSeries(ma1_array, true);
   CopyBuffer(mv1, 0, 0, 3, ma1_array);
   double ma1_value = ma1_array[0];
   printf("Moving average value: ", ma1_value);
   return true;
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