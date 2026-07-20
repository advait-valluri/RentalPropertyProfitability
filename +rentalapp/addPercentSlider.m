function slider = addPercentSlider(parent, labelText, value, callback)
    uilabel(parent, 'Text', labelText);

    sliderGrid = uigridlayout(parent, [1 2]);
    sliderGrid.ColumnWidth = {'1x', 42};
    sliderGrid.RowHeight = {'1x'};
    sliderGrid.Padding = [0 0 0 0];
    sliderGrid.ColumnSpacing = 6;

    slider = uislider(sliderGrid, ...
        'Limits', [0 100], ...
        'Value', value, ...
        'MajorTicks', [], ...
        'MinorTicks', []);
    valueLabel = uilabel(sliderGrid, ...
        'Text', sprintf('%.0f%%', value), ...
        'HorizontalAlignment', 'right');

    slider.ValueChangingFcn = @(~, event) setChangingValue(valueLabel, event.Value);
    slider.ValueChangedFcn = @(~, ~) setChangedValue(slider, valueLabel, callback);
end

function setChangingValue(valueLabel, value)
    valueLabel.Text = sprintf('%.0f%%', value);
end

function setChangedValue(slider, valueLabel, callback)
    value = round(slider.Value);
    slider.Value = value;
    valueLabel.Text = sprintf('%.0f%%', value);
    callback();
end
