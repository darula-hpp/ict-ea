# ICT Expert Advisor (EA)

An automated trading system for MetaTrader 5 (MT5) that implements Inner Circle Trader (ICT) concepts for trading spot Gold. This Expert Advisor uses order blocks, market structure, and smart money concepts to identify high-probability trading opportunities.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Trading Strategy](#trading-strategy)
- [Installation](#installation)
- [Configuration](#configuration)
- [Risk Management](#risk-management)
- [Trading Logic](#trading-logic)
- [Requirements](#requirements)
- [Disclaimer](#disclaimer)
- [Author](#author)

## 🎯 Overview

This Expert Advisor is designed to trade spot Gold (XAUUSD) using ICT methodology, focusing on:

- **Order Block Detection**: Identifies significant price levels where institutional orders are placed
- **Market Structure Analysis**: Analyzes price action to determine trend direction
- **Smart Money Concepts**: Implements weekly open levels and market session analysis
- **Risk Management**: Dynamic position sizing and stop-loss management

## ✨ Features

### Core Trading Features
- **Order Block Recognition**: Automatically detects order blocks based on candle body-to-range ratio
- **Market Structure Analysis**: Uses moving averages to determine market bias
- **Weekly Open Integration**: Trades based on weekly opening levels
- **Session-Based Trading**: Optimized for London and New York sessions
- **Dynamic Position Sizing**: Risk-adjusted lot sizing based on stop-loss distance

### Risk Management
- **Adaptive Stop Loss**: Dynamic stop-loss placement based on market volatility
- **Trailing Stop**: Automatic stop-loss modification for profit protection
- **Daily Trade Limit**: Prevents overtrading with daily position limits
- **Volatility Filter**: Avoids trading during high volatility periods

### Technical Indicators
- **Moving Averages**: Dual MA system (5-period and 30-period) for trend analysis
- **RSI Integration**: Momentum analysis (currently commented out)
- **Price Action Analysis**: Candle pattern recognition and market structure

## 📈 Trading Strategy

### Entry Conditions

#### Long Positions (Buy)
1. **Weekly Open Above Current Price**: W_O < current bid
2. **Previous Candle Bearish**: Previous H1 candle closed below its open
3. **Order Block Confirmation**: Previous candle meets order block criteria (>10% body-to-range ratio)
4. **Market Structure**: Price above previous close relative to historical lows
5. **Trend Confirmation**: Moving averages indicate bullish bias

#### Short Positions (Sell)
1. **Weekly Open Below Current Price**: W_O > current ask
2. **Previous Candle Bullish**: Previous H1 candle closed above its open
3. **Order Block Confirmation**: Previous candle meets order block criteria
4. **Market Structure**: Price below previous close relative to historical highs
5. **Trend Confirmation**: Moving averages indicate bearish bias

### Exit Strategy
- **Take Profit**: Dynamic TP based on stop-loss distance (3x-4x multiplier)
- **Stop Loss**: Previous candle's low (long) or high (short)
- **Trailing Stop**: Moves to breakeven + 2x stop-loss distance when profitable

## 🚀 Installation

1. **Download the EA files**:
   - `ICT_EA.mq5` - Main Expert Advisor file
   - `ICT_EA.mqproj` - Project configuration file

2. **Install in MetaTrader 5**:
   - Copy files to your MT5 `Experts` folder
   - Restart MetaTrader 5
   - Compile the EA in MetaEditor

3. **Attach to Chart**:
   - Drag the EA to a Gold (XAUUSD) H1 chart
   - Configure input parameters
   - Enable auto-trading

## ⚙️ Configuration

### Input Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `ORDER_BLOCK_THRESHOLD` | 10 | Minimum body-to-range ratio for order block detection (%) |
| `MA1_PERIOD` | 5 | Fast moving average period |
| `MA2_PERIOD` | 30 | Slow moving average period |
| `RSIperiod` | 14 | RSI calculation period |

### Internal Parameters

| Parameter | Value | Description |
|-----------|-------|-------------|
| `RISK` | 20 | Risk percentage per trade |
| `LOOK_BACK` | 24 | Periods for trend analysis |
| `SHIFT_BACK_START` | 10 | Hours to look back for price analysis |
| `SHIFT_DURATION` | 96 | Duration of price analysis window |
| `NUM_STOP_LOSS_CANDLES` | 5 | Candles for volatility calculation |

## 🛡️ Risk Management

### Position Sizing
- **Dynamic Lot Calculation**: Based on stop-loss distance and account risk
- **Minimum Lot Size**: 0.01 lots
- **Maximum Lot Size**: 0.04 lots (for small stop-loss distances)
- **Risk Per Trade**: 2% of account balance

### Stop Loss Management
- **Initial Stop Loss**: Previous candle's low/high
- **Minimum Distance**: 0.5 pips (adjusted if too small)
- **Maximum Distance**: 4.5 pips (capped for risk control)
- **Trailing Stop**: Activated when profit reaches 2x stop-loss distance

### Trade Filters
- **Daily Limit**: One trade per day maximum
- **Volatility Filter**: No trading when current range > 80% of 5-day average
- **Session Filter**: Trades during active market hours
- **Trend Filter**: Only trades in direction of moving average trend

## 🧠 Trading Logic

### Market Analysis
1. **Weekly Open Calculation**: Captured on Monday at 1 AM
2. **Daily Range Analysis**: Calculates 5-day average daily range
3. **Price Structure**: Analyzes previous 10-106 hours of price action
4. **Order Block Detection**: Identifies significant price levels

### Entry Timing
- **Session**: Active during London and New York sessions
- **Time Filter**: Trades from 0:00 to 23:59 (configurable)
- **Volatility Check**: Avoids trading during excessive volatility
- **Structure Confirmation**: Waits for proper market structure setup

### Exit Management
- **Take Profit**: 3x-4x stop-loss distance (based on daily volatility)
- **Stop Loss**: Previous candle's extreme
- **Trailing**: Moves stop to breakeven + 2x SL when profitable

## 📋 Requirements

### MetaTrader 5
- **Platform**: MetaTrader 5 (Build 3815 or higher)
- **Account**: Demo or Live account with Gold trading
- **Symbol**: XAUUSD (Spot Gold)
- **Timeframe**: H1 (1 Hour)

### Trading Environment
- **VPS Recommended**: For 24/7 operation
- **Stable Internet**: Reliable connection for trade execution
- **Sufficient Margin**: Minimum 1:100 leverage recommended

### Market Conditions
- **Liquidity**: Best during London and New York sessions
- **Volatility**: Optimal in normal market conditions
- **Spread**: Works best with tight spreads (< 3 pips)

## ⚠️ Disclaimer

**IMPORTANT RISK WARNING**: Trading foreign exchange and CFDs involves substantial risk of loss and is not suitable for all investors. Past performance is not indicative of future results. This Expert Advisor is provided for educational purposes only.

### Key Risks
- **Market Risk**: Gold prices can move against positions
- **Technical Risk**: EA may not work in all market conditions
- **Execution Risk**: Slippage and requotes may affect performance
- **System Risk**: Technical failures could impact trading

### Recommendations
- **Start with Demo**: Test thoroughly on demo account first
- **Small Position Sizes**: Begin with minimal risk
- **Monitor Performance**: Regular review of trading results
- **Risk Management**: Never risk more than you can afford to lose

## 👨‍💻 Author

**Olebogeng Mbedzi**
- **Platform**: MetaTrader 5
- **Language**: MQL5
- **Strategy**: ICT (Inner Circle Trader) Methodology
- **Specialization**: Gold Trading, Order Blocks, Market Structure

---

*This Expert Advisor implements advanced trading concepts and should be thoroughly tested before live trading. Always practice proper risk management and never trade with money you cannot afford to lose.*
