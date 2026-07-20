function text = formatPercent(value)
    if isnan(value) || isinf(value)
        text = '-';
    else
        text = sprintf('%.2f%%', value);
    end
end
