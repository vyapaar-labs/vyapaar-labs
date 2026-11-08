# 0002 — Strategy Execution, Hyperparameter Tuning, and Optimal Trade Suggestion Engine for CLI & TUI

> **Status**: Approved Architecture & Implementation Specification  
> **Target Scope**: `vyapaar-ui` (`vyapaar-cli`, `vyapaar-tui`, `vyapaar-ui-core`, `vyapaar-ui-app`), `vyapaar-runtime` (`vyapaar-runtime-strategy`, `vyapaar-runtime-backtest`, `vyapaar-runtime-enhancer`), `vyapaar-strategies`, `vyapaar-agent` (`vyapaar-agent-chat-tools`)  
> **Reference Inputs**:  
> - `docs/plans/0001-fincept-quantcepts-gap-closure-and-feature-roadmap.md`  
> - `docs/design/architecture.md` (Strategic & Tactical DDD invariants)  
> - `vyapaar-strategies/schema/strategy-manifest.schema.json`  
> - `vyapaar-runtime/crates/vyapaar-runtime-enhancer` (GaOptimizer, BayesianOptimizer, OverfittingGuardrails)  
> - `vyapaar-ui/crates/vyapaar-cli` & `vyapaar-ui/crates/vyapaar-tui`  

---

## 0. Executive Summary & Problem Statement

Vyapaar currently possesses an interactive terminal environment across two primary user interfaces:
1. **Native CLI (`vyapaar-cli`)**: Provides conversational commands (`ask`, `chat`), autonomous jobs (`jobs`), diagnostic checks (`doctor`), and static code safety audits (`verify`).
2. **Workstation TUI (`vyapaar-tui`)**: A 7-tab Ratatui terminal workstation featuring an active Watchlist, an in-process streaming LLM Agent Chat desk, and a comprehensive slash command palette.

However, a critical gap separates the user interfaces from the platform's core algorithmic compute:
- **No Strategy Execution in CLI/TUI**: Neither the CLI nor TUI can discover, load, or execute strategies directly. The `Algos` and `Backtest` tabs in `vyapaar-tui` render static placeholder screens.
- **Disconnected Parameter Tuning**: Advanced hyperparameter search engines in `vyapaar-runtime-enhancer` (Bayesian optimization, Genetic Algorithms, parameter grid sweeps, Walk-Forward Analysis, and Deflated Sharpe Ratio guardrails) are not hooked into the terminal frontends.
- **Missing Actionable Trade Suggestions**: While `vyapaar-agent-chat-tools` contains deterministic calculators for position sizing (`PositionSizingArgs`), statutory costs (`StatutoryCostsArgs`), and return metrics, the system does not combine tuned strategy parameters, recent market data, and risk budgeting to synthesize a concrete, actionable **Optimal Trade Suggestion**.

This specification defines the architecture, data contracts, and implementation roadmap to wire strategy execution and automated parameter tuning into the CLI and TUI, delivering mathematically grounded, risk-budgeted trade suggestions.

---

## 1. End-to-End System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                   PRESENTATION LAYER (vyapaar-ui)                                       │
│  ┌─────────────────────────────────────────────────┐   ┌─────────────────────────────────────────────┐  │
│  │ Native CLI (vyapaar-cli)                        │   │ Ratatui Workstation (vyapaar-tui)           │  │
│  │ • `vyapaar strategy list`                       │   │ • Tab 5: Backtest (Curves, Metrics, Suggest)│  │
│  │ • `vyapaar strategy run <name> [options]`       │   │ • Tab 6: Algos (Catalog, Status, Hotkeys)   │  │
│  │ • `vyapaar strategy tune <name> [options]`      │   │ • Slash commands (/run, /tune, /suggest)    │  │
│  │ • `vyapaar strategy suggest <name> [options]`   │   │ • Agent Chat Tool Integration               │  │
│  └────────────────────────┬────────────────────────┘   └──────────────────────┬──────────────────────┘  │
└───────────────────────────┼───────────────────────────────────────────────────┼─────────────────────────┘
                            │                                                   │
                            ▼                                                   ▼
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                 STRATEGY EXECUTION & TUNING BRIDGE                                      │
│  ┌─────────────────────────────────┐ ┌──────────────────────────────────┐ ┌───────────────────────────┐  │
│  │ Strategy Catalog Provider       │ │ Optimization & Sweep Controller  │ │ Trade Suggestion Engine   │  │
│  │ • Discovers Built-in Strategies │ │ • Parameter Grid / Bayesian / GA │ │ • Signal Detection        │  │
│  │ • Loads TOML/JSON Manifests     │ │ • Fitness Evaluation (Sharpe/PnL)│ │ • ATR Stop-Loss & Targets │  │
│  │ • Parses ParameterSpec ranges   │ │ • Overfitting Guardrails (DSR)   │ │ • Risk-Budgeted Sizing    │  │
│  └─────────────────────────────────┘ └──────────────────────────────────┘ └───────────────────────────┘  │
└───────────────────────┬───────────────────────────────┬───────────────────────────────┬─────────────────┘
                        │                               │                               │
                        ▼                               ▼                               ▼
┌───────────────────────────────┐   ┌───────────────────────────┐   ┌─────────────────────────────────────┐
│ vyapaar-runtime-strategy      │   │ vyapaar-runtime-enhancer  │   │ vyapaar-agent-chat-tools            │
│ • Strategy Trait              │   │ • EnhancerEngine          │   │ • PositionSizingArgs                │
│ • StrategyManifest            │   │ • BayesianOptimizer       │   │ • StatutoryCostsArgs (STT/GST)      │
│ • SmaCrossover, RsiReversal   │   │ • GaOptimizer, DSR, PBO   │   │ • RiskEngine (SEBI Limits)          │
│ • TurtleBreakout, TWAPSlicer  │   │ • BacktestEngine Kernel   │   │ • MarketQuoteReader                 │
└───────────────────────────────┘   └───────────────────────────┘   └─────────────────────────────────────┘
```

---

## 2. Strategy Catalog & Manifest Discovery

### 2.1 Supported Strategy Classes
The execution bridge unifies two classes of strategies under the canonical `Strategy` trait:

1. **Rust Built-in Strategies (`vyapaar-runtime-strategy`)**:
   - `sma_crossover`: Moving average crossover with parameters `fast_period` (default 10, range 5..50), `slow_period` (default 50, range 20..200), and `quantity`.
   - `rsi_reversal`: Relative Strength Index mean-reversion with parameters `period` (default 14, range 7..30), `oversold` (default 30, range 15..40), `overbought` (default 70, range 60..85).
   - `buy_and_hold`: Passive benchmark accumulator with parameter `quantity`.
   - `dyn_strategy`: Dynamic IR-driven AST strategy.

2. **Manifest-Declared Strategies (`vyapaar-strategies`)**:
   - TOML/JSON manifests located in `vyapaar-strategies/manifests/strategies/*.toml` (e.g., `turtle_breakout.toml`, `twap_slicer.toml`, `turtle_twap_basket.toml`).
   - Manifests declare exact parameter search spaces:
     ```toml
     name = "turtle_breakout"
     version = "0.1.0"
     strategy = "vyapaar_strategies.strategies.turtle:TurtleBreakout"
     
     [parameters.entry_period]
     default = 20
     min = 5
     max = 60
     step = 1

     [parameters.exit_period]
     default = 10
     min = 5
     max = 60
     step = 1
     ```

### 2.2 Unified Strategy Model
```rust
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StrategyDescriptor {
    pub id: String,
    pub name: String,
    pub version: String,
    pub description: String,
    pub source: StrategySourceKind, // Builtin | Manifest | Script
    pub parameters: BTreeMap<String, ParameterSpec>,
    pub target_instruments: Vec<String>,
}
```

---

## 3. Parameter Tuning & Overfitting Guardrails

### 3.1 Parameter Search Protocols
Parameter tuning runs through three tiers of search based on dimensionality:

1. **Deterministic Grid Sweep**:
   - Used when total combinations $\prod \left(\frac{\text{max}_i - \text{min}_i}{\text{step}_i} + 1\right) \le 100$.
   - Evaluates all candidate parameter vectors across historical bar data using `BacktestEngine`.
2. **Bayesian Hyperparameter Search (`BayesianOptimizer`)**:
   - Used for continuous/fine-grained spaces to maximize the surrogate acquisition function (Expected Improvement).
3. **Genetic Algorithm Optimizer (`GaOptimizer`)**:
   - Used for high-dimensional combinatorial parameter spaces ($\ge 4$ parameters).

### 3.2 Fitness & Statistical Overfitting Guardrails
Tuning does not simply select the highest historical net PnL (which suffers from selection bias). Each candidate parameter set is vetted against:

1. **Fitness Objective**:
   $$\text{Fitness} = \text{Sharpe Ratio} \times \left(1 - \frac{\text{Max Drawdown}}{0.50}\right) \times \min\left(1.0, \frac{\text{Total Trades}}{30}\right)$$
   This penalizes strategies with excessive drawdowns or insufficient statistical sample sizes.
2. **Deflated Sharpe Ratio (DSR)**:
   - Evaluates the probability that the best Sharpe ratio arose from data-mining multiple trials:
     $$\text{DSR} = \Phi\left( \frac{(\widehat{\text{SR}} - \text{SR}^*) \sqrt{N - 1}}{\sqrt{1 - \gamma_3 \widehat{\text{SR}} + \frac{\gamma_4 - 1}{4} \widehat{\text{SR}}^2}} \right)$$
   - Rejects parameter configurations where $\text{DSR} < 0.90$ (90% confidence).
3. **Probability of Backtest Overfitting (PBO)**:
   - Uses Combinatorially Symmetric Cross-Validation (CSCV) across sub-periods to ensure $\text{PBO} < 0.30$.

---

## 4. Optimal Trade Suggestion Formulation

Once the optimal parameter set $\boldsymbol{\theta}^*$ is identified and validated, the engine computes an actionable trade recommendation by projecting $\boldsymbol{\theta}^*$ onto the current market tick/bar:

### 4.1 Trade Geometry
1. **Current Market State & Bias**:
   - `BUY` (Long), `SELL` (Short), or `NEUTRAL` (Hold/Cash).
2. **Entry Level ($P_{\text{entry}}$)**:
   - For breakout strategies: highest high of the tuned entry period ($H_{N^*}$).
   - For mean-reversion: current limit price or market ask.
3. **Stop-Loss Level ($P_{\text{sl}}$)**:
   - Volatility-adjusted via Average True Range (ATR):
     $$P_{\text{sl}} = P_{\text{entry}} - (k \times \text{ATR}_{14})$$
     where $k$ is strategy-defined (e.g. $k = 2.0$ for Turtle).
4. **Target Objectives ($P_{\text{target}}$)**:
   - Target 1 ($1:2$ Risk-Reward): $P_{\text{t1}} = P_{\text{entry}} + 2 \times |P_{\text{entry}} - P_{\text{sl}}|$
   - Target 2 ($1:3$ Risk-Reward): $P_{\text{t2}} = P_{\text{entry}} + 3 \times |P_{\text{entry}} - P_{\text{sl}}|$

### 4.2 Risk-Budgeted Position Sizing
Position sizing is computed using `vyapaar-agent-chat-tools::calc::PositionSizingArgs`:
$$\text{Risk Amount} = \text{Account Capital} \times \text{Risk \%} \quad (\text{e.g. } ₹10,00,000 \times 1\% = ₹10,000)$$
$$\text{Shares} = \left\lfloor \frac{\text{Risk Amount}}{|P_{\text{entry}} - P_{\text{sl}}|} \right\rfloor$$
The quantity is further rounded to the minimum instrument lot size and checked against SEBI margin exposure limits.

### 4.3 Indian Statutory Transaction Cost Breakdown
Calculated via `StatutoryCostsArgs`:
- **Securities Transaction Tax (STT)**: 0.1% on delivery buy/sell, 0.025% on intraday sell.
- **Exchange Turnover Charges**: NSE ₹0.00325%.
- **SEBI Turnover Fee**: ₹10 per crore.
- **Stamp Duty**: 0.015% on buy.
- **GST**: 18% on (brokerage + exchange charges + SEBI charges).

---

## 5. CLI Specification (`vyapaar-cli`)

### 5.1 Command Hierarchy
```text
vyapaar strategy
  ├── list                        List all registered built-in and manifest strategies
  ├── run <NAME> [OPTIONS]        Run backtest on a strategy with default or custom params
  ├── tune <NAME> [OPTIONS]       Tune parameters using grid sweep / Bayesian search
  └── suggest <NAME> [OPTIONS]    Tune parameters & generate an optimal trade suggestion
```

### 5.2 Command Arguments & Flags
```rust
#[derive(Debug, Clone, PartialEq, Eq, Args)]
pub struct StrategyRunArgs {
    pub name: String,
    #[arg(short, long, default_value = "NSE:NIFTY50-INDEX")]
    pub symbol: String,
    #[arg(long)]
    pub params: Option<String>, // JSON override e.g. '{"fast_period":12}'
    #[arg(long, default_value = "1000000")]
    pub capital: Decimal,
    #[arg(long, value_enum, default_value = "text")]
    pub format: OutputFormat,
}

#[derive(Debug, Clone, PartialEq, Eq, Args)]
pub struct StrategyTuneArgs {
    pub name: String,
    #[arg(short, long, default_value = "NSE:NIFTY50-INDEX")]
    pub symbol: String,
    #[arg(long, default_value = "sharpe")]
    pub metric: String, // sharpe | pnl | calmar
    #[arg(long, default_value = "grid")]
    pub method: String, // grid | bayesian | ga
    #[arg(long, default_value = "1000000")]
    pub capital: Decimal,
    #[arg(long, value_enum, default_value = "text")]
    pub format: OutputFormat,
}

#[derive(Debug, Clone, PartialEq, Eq, Args)]
pub struct StrategySuggestArgs {
    pub name: String,
    #[arg(short, long, default_value = "NSE:NIFTY50-INDEX")]
    pub symbol: String,
    #[arg(long, default_value = "1000000")]
    pub capital: Decimal,
    #[arg(long, default_value = "1.0")]
    pub risk_pct: Decimal,
    #[arg(long, value_enum, default_value = "text")]
    pub format: OutputFormat,
}
```

### 5.3 CLI Output Example
```text
$ vyapaar strategy suggest turtle_breakout --symbol NSE:NIFTY50-INDEX --capital 1000000 --risk-pct 1.0

╔═══════════════════════════════════════════════════════════════════════════╗
║          VYAPAAR OPTIMAL TRADE SUGGESTION: TURTLE BREAKOUT                ║
╚═══════════════════════════════════════════════════════════════════════════╝

1. PARAMETER TUNING AUDIT
   ─────────────────────────────────────────────────────────────────────────
   Parameter       Default     Tuned Value     Search Space
   entry_period    20          24              5 .. 60 (step 1)
   exit_period     10          12              5 .. 60 (step 1)

   Validation Metrics:
   • Annualized Sharpe : 1.94 (vs 1.41 default)
   • Deflated Sharpe   : 94.2% confidence (Passes DSR >= 90% guardrail)
   • Max Drawdown      : 4.15% (vs 7.80% default)
   • Win Rate / Profit : 58.3% | Profit Factor: 2.18

2. OPTIMAL TRADE EXECUTION CARD
   ─────────────────────────────────────────────────────────────────────────
   • Target Asset      : NSE:NIFTY50-INDEX
   • Strategy Signal   : BUY / LONG (Breakout Confirmed)
   • Entry Price       : ₹24,150.00
   • Stop Loss         : ₹23,850.00 (-₹300.00 / -1.24% / 2.0 ATR)
   • Profit Target 1   : ₹24,750.00 (+₹600.00 / +2.48% | R:R = 1:2.0)
   • Profit Target 2   : ₹25,050.00 (+₹900.00 / +3.73% | R:R = 1:3.0)

3. CAPITAL ALLOCATION & RISK BUDGETING
   ─────────────────────────────────────────────────────────────────────────
   • Available Capital : ₹10,00,000.00
   • Risk Budget (1.0%): ₹10,000.00
   • Recommended Size  : 33 units
   • Total Notional    : ₹7,96,950.00 (Margin Utilization: 79.7%)
   • Est. Statutory Fee: ₹214.30 (STT, GST, SEBI Turnover, Stamp Duty)
   • Net Potential R:R : 1 : 1.96 (accounting for all statutory friction)
```

---

## 6. TUI Specification (`vyapaar-tui`)

### 6.1 Algos Tab (`ActiveTab::Algos`)
Replaces `draw_placeholder` with an interactive split view:
- **Left Panel (60% width)**: Table of registered algorithms.
  - Columns: `Name`, `Version`, `Status` (Active/Paused/Stopped), `Sharpe`, `Instruments`.
  - Navigation: `Up`/`Down` arrows or `j`/`k`.
- **Right Panel (40% width)**: Selected Strategy Details & Parameter Inspector.
  - Description, author, contract API version.
  - Parameter list with declared defaults and sweep bounds (`min..max:step`).
- **Interactive Action Bar**:
  - `[Enter]` Backtest Strategy | `[T]` Tune Parameters | `[S]` Suggest Trade | `[Space]` Toggle Active.

### 6.2 Backtest Tab (`ActiveTab::Backtest`)
Replaces `draw_placeholder` with a 4-quadrant analytical view:
- **Top Left**: Key Performance Indicator (KPI) cards (Net PnL, Total Return %, Sharpe Ratio, Max Drawdown %, Win Rate, Total Trades).
- **Top Right**: Parameter Delta comparison table (Default vs Tuned values).
- **Bottom Left**: High-resolution ASCII/Braille Equity Curve & Drawdown chart using `ratatui::widgets::Sparkline`.
- **Bottom Right**: **Optimal Trade Suggestion Card** rendering signal direction, entry, stop loss, profit targets, and risk-sized share count.

### 6.3 Command Palette Slash Commands
Adds four new slash commands to `SLASH_COMMANDS`:
- `/algos`: Switch directly to Algorithm Management tab.
- `/backtest [strategy]`: Execute backtest on specified or selected strategy.
- `/tune [strategy]`: Launch parameter optimization dialog/runner.
- `/suggest [strategy]`: Generate optimal trade suggestion for active instrument.

### 6.4 Conversational Agent Desk Integration
Wires the `StrategyExecutionBridge` into `terminal.rs` and `runner.rs` chat requests:
- Injects `StrategyRunTool`, `StrategyTuneTool`, and `TradeSuggestionTool` into `ChatRequest.tools`.
- When a user asks:
  *"How should I trade RELIANCE using RSI reversal today?"*
  The LLM streams tool calls to tune the RSI parameters on recent RELIANCE bars and formats the optimal trade suggestion card directly into the chat transcript.

---

## 7. Implementation Phasing & Conformance Matrix

| Phase | Target Module | Scope of Work |
| :--- | :--- | :--- |
| **Phase 1** | `vyapaar-ui-core` / Bridge | Build `StrategyCatalog`, `StrategyRunnerBridge`, parameter sweep adapter, and `TradeSuggestionEngine` |
| **Phase 2** | `vyapaar-cli` | Implement `StrategyCommand` in `args.rs` and execution handlers in `runner.rs` with text and JSON formatters |
| **Phase 3** | `vyapaar-tui` | Implement `draw_algos` and `draw_backtest` in `ui.rs`, connect `AlgosFeature` and `BacktestFeature` in `app.rs` |
| **Phase 4** | `vyapaar-agent-chat-tools` | Expose strategy runner and suggestion generator as advisory tools for CLI `ask`/`chat` and TUI `AgentChat` |
| **Phase 5** | Verification & Tests | Unit tests for parameter sweep accuracy, DSR calculation, risk sizing math, and CLI/TUI integration tests |

### Architectural Invariants
1. **Zero Floats Rule**: All prices, capital, risk percentages, and statutory fees must strictly use `rust_decimal::Decimal`.
2. **NoFX Advisory Principle**: Trade suggestions are purely advisory recommendations; live order execution requires explicit user authorization.
3. **WASM Safety**: `vyapaar-ui-core` and `vyapaar-ui-app` must remain free from `tokio`, threads, and blocking I/O.
