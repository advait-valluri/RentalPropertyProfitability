function rate = germanTransferTaxRate(stateName)
    data = rentalapp.germanTransferTaxRates();
    idx = strcmp(data(:, 1), stateName);
    if any(idx)
        rate = data{find(idx, 1), 2};
    else
        rate = 5.0;
    end
end
