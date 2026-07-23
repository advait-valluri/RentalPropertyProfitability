# Rental Property Profitability App

Programmatic MATLAB app for evaluating the profitability of owning a rental property. The app focuses on cash invested, monthly rental cash flow, financing, German purchase closing costs, agent commission, HOA cost split, and the time needed to recover the upfront cash investment. All monetary values in the app are displayed in euro.

Run from MATLAB:

```matlab
RentalPropertyProfitabilityApp
```

The app is split into a small launcher and the `+rentalapp` package for UI construction, calculations, plotting, and formatting.

## App Structure

The app has four tabs:

- `Forward calculation`: starts from a property purchase price and calculates monthly cash flow, return metrics, break-even timing, equity, and long-term performance.
- `Max price from rent`: starts from a monthly rent amount and back-calculates the maximum property purchase price that satisfies either break-even cash flow or a target cash-on-cash return.
- `Tilgung sensitivity`: uses the forward-tab scenario as a baseline and shows how monthly payment and after-tax cash flow change across a range of Tilgung rates.
- `Payment schedule`: shows monthly interest and principal payments with yearly total rows inserted as intermediate roll-ups.

The `File` menu lets you save all current parameters to a `.mat` session file, load a previously saved parameter set, or exit the app.

The current model includes:

- Purchase price, monthly rent, down payment, interest rate, and loan term.
- German closing-cost components: real estate transfer tax, notary cost, and land registry cost.
- German federal state selection, which auto-fills the real estate transfer tax rate.
- Two financing modes: `Loan term` and `Interest + Tilgung`.
- A minimum `Tilgung` constraint used in both the forward and reverse calculations.
- Optional real estate agent commission at `3.57%` of purchase price.
- One-time renovation costs.
- HOA contribution, with a slider snapped to `2%` increments and a synced exact numeric entry for the share transferable to the tenant.
- Annual maintenance costs as an owner-paid recurring expense.
- Simplified German rental tax relief based on standard residential `AfA`, mortgage interest, owner-paid operating costs, and a user-entered marginal tax rate.
- Vacancy, rent growth, expense inflation, appreciation, and analysis horizon.

## Core Calculations

Initial cash invested is:

```text
Down payment
+ German closing costs
+ Agent commission, if enabled
+ One-time renovation costs
```

German closing costs are:

```text
Purchase price * (transfer tax % + notary % + land registry %) / 100
```

`Real estate transfer tax (%)` is the state-specific property acquisition tax and is used only in the upfront closing-cost calculation.

Monthly cash flow is:

```text
Effective rent - owner-paid operating expenses - mortgage payment + tax saving
```

Effective rent accounts for vacancy. Owner-paid operating expenses are:

```text
HOA contribution * (1 - transferable HOA % / 100)
+ maintenance costs / 12
```

The tax module uses a simplified German rental-property model:

```text
Tax-deductible amount
= standard residential AfA on building value only
+ mortgage interest
+ owner-paid operating expenses
```

```text
Tax saving = tax-deductible amount * marginal tax rate / 100
```

`Marginal tax rate (%)` is the only tax rate used in the tax-saving calculation. The app applies this user-entered rate as a flat multiplier to the deductible amount. It does not calculate the German progressive income-tax schedule, solidarity surcharge, church tax, or tax on positive rental profits.

Financing can be modeled in two ways:

- `Loan term`: payment is derived from loan amount, interest rate, and loan term.
- `Interest + Tilgung`: payment is derived from loan amount and the sum of the interest rate and initial `Tilgung`.

The app also reports the first-year effective `Tilgung` rate and checks it against the user-entered minimum `Tilgung (%/yr)` constraint.

Standard residential `AfA` is inferred from the building completion year:

- Before `1925`: `2.5%`
- `1925` to `2023`: `2.0%`
- `2024` onward: `3.0%`

The app assumes the user provides the building share of the purchase price that is attributable to the depreciable building rather than land. This is a simplified estimate, not a full German income-tax model, and it does not cover special depreciation rules, legal eligibility checks, or taxation of positive rental profits.

## Plots

### Cumulative Cash Flow

This plot appears in the `Forward calculation` tab. It shows the running cash position over the analysis period after subtracting the initial cash invested.

```text
Cumulative cash flow = cumulative monthly cash flow - initial cash invested
```

The curve usually starts negative because the upfront investment is paid at the beginning. The horizontal zero line is the break-even reference. If the curve crosses zero, the marker shows the break-even point: the time when cumulative monthly cash flow has recovered the initial cash invested.

If the curve never reaches zero, the property does not recover the upfront cash investment within the selected analysis horizon.

### Monthly Performance

This plot appears in the `Forward calculation` tab. It compares the major monthly operating lines over time:

- `Income`: effective rent after vacancy.
- `Operating expenses`: owner-paid HOA expense plus maintenance, grown by expense inflation.
- `Debt service`: monthly mortgage payment.
- `Tax saving`: estimated monthly tax relief from deductible costs.
- `After-tax cash flow`: income minus operating expenses minus debt service plus tax saving.

This plot is useful for seeing whether the property is cash-flow positive or negative and how rent growth and expense inflation change the monthly result over time.

### Equity And Net Position

This plot appears in the `Forward calculation` tab and shows two long-term value measures:

- `Equity`: estimated property value minus remaining loan balance.
- `Equity + cash flow - initial cash`: equity plus cumulative cash flow, after subtracting the initial cash invested.

Equity increases when the loan principal is paid down and when the property appreciates. The net-position line adds the cash-flow effect, so it gives a broader view of total economic position than monthly cash flow alone.

### Annual Cash-On-Cash Return

This plot appears in the `Forward calculation` tab. It shows each year's cash-on-cash return:

```text
Annual cash-on-cash return = annual cash flow / initial cash invested * 100
```

The zero line separates years with positive cash return from years with negative cash return. This plot helps show whether the rental improves or worsens over time as rent and expenses change.

### Maximum Price Versus Rent

This plot appears in the `Max price from rent` tab. It shows how the calculated maximum purchase price changes across a range of monthly rent values around the rent entered by the user.

The highlighted marker shows the current rent input and the corresponding maximum purchase price. The calculation follows the selected reverse mode:

- `Break-even cash flow`: maximum price where first-month cash flow is at least zero.
- `Target cash-on-cash`: maximum price where the target annual cash-on-cash return is met.

This plot is useful for understanding how sensitive the purchase-price ceiling is to rent assumptions.

### Sensitivity Around Maximum Price

This plot appears in the `Max price from rent` tab. It evaluates purchase prices around the calculated maximum price and shows two metrics:

- Left axis: monthly cash flow.
- Right axis: cash-on-cash return.

The zero line on the cash-flow axis shows the break-even monthly cash-flow point. In target-return mode, the plot also shows the selected target cash-on-cash return as a reference line.

This plot helps explain why the app selected the reported maximum price. Prices below the maximum should generally improve cash flow and cash-on-cash return; prices above it should weaken the result and eventually fail the selected constraint.

### Tilgung Sensitivity

This plot appears in the `Tilgung sensitivity` tab. It varies the initial `Tilgung` rate across a user-defined range while keeping the other forward-tab scenario inputs fixed.

- Left axis: monthly financing payment.
- Right axis: after-tax monthly cash flow.

This view is useful for seeing how more aggressive principal repayment affects affordability and cash flow before deciding on a financing structure.

### Payment Schedule

This tab is driven by the current `Forward calculation` scenario and updates automatically when the forward inputs change.

The table includes:

- monthly payment rows
- yearly total rows inserted after each year
- interest paid
- principal paid
- total payment
- cumulative interest
- cumulative principal
- remaining balance

Yearly total rows are highlighted and all money values are formatted as full euro amounts rather than scientific notation.

## Maintainer Tools

This repository includes a local Codex skill for strict MATLAB review:

```text
.agents/skills/matlab-review/SKILL.md
```

Use it when reviewing MATLAB files for modern R2021a+ conventions:

```text
$matlab-review <filename>
```

The skill checks for common maintainability issues such as `nargin` or `inputParser` usage where an `arguments` block would be clearer, un-vectorized loops, missing preallocation, and missing H1 documentation lines.
