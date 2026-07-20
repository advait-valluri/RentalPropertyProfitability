# Rental Property Profitability App

Programmatic MATLAB app for evaluating the profitability of owning a rental property. The app focuses on cash invested, monthly rental cash flow, financing, German purchase closing costs, agent commission, HOA cost split, and the time needed to recover the upfront cash investment.

Run from MATLAB:

```matlab
RentalPropertyProfitabilityApp
```

The app is split into a small launcher and the `+rentalapp` package for UI construction, calculations, plotting, and formatting.

## App Structure

The app has two tabs:

- `Forward calculation`: starts from a property purchase price and calculates monthly cash flow, return metrics, break-even timing, equity, and long-term performance.
- `Max price from rent`: starts from a monthly rent amount and back-calculates the maximum property purchase price that satisfies either break-even cash flow or a target cash-on-cash return.

The current model includes:

- Purchase price, monthly rent, down payment, interest rate, and loan term.
- German closing-cost components: real estate transfer tax, notary cost, and land registry cost.
- German federal state selection, which auto-fills the real estate transfer tax rate.
- Optional real estate agent commission at `3.57%` of purchase price.
- One-time renovation costs.
- HOA contribution, with a slider for the share transferable to the tenant.
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

Monthly cash flow is:

```text
Effective rent - owner-paid HOA expense - mortgage payment
```

Effective rent accounts for vacancy. Owner-paid HOA expense is only the non-transferable HOA share:

```text
HOA contribution * (1 - transferable HOA % / 100)
```

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
- `Operating expenses`: owner-paid HOA expense, grown by expense inflation.
- `Debt service`: monthly mortgage payment.
- `Cash flow`: income minus operating expenses minus debt service.

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
