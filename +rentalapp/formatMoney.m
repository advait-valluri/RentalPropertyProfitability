function text = formatMoney(app, value)
    if isnan(value) || isinf(value)
        text = '-';
    else
        text = sprintf('%s%.0f', app.Currency, value);
    end
end
