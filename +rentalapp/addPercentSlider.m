function control = addPercentSlider(parent, labelText, value, callback)
    uilabel(parent, 'Text', labelText);

    sliderGrid = uigridlayout(parent, [1 2]);
    sliderGrid.ColumnWidth = {'1x', 70};
    sliderGrid.RowHeight = {'1x'};
    sliderGrid.Padding = [0 0 0 0];
    sliderGrid.ColumnSpacing = 6;

    slider = uislider(sliderGrid, ...
        'Limits', [0 100], ...
        'Value', value, ...
        'MajorTicks', [], ...
        'MinorTicks', []);
    field = uieditfield(sliderGrid, 'numeric', ...
        'Value', value, ...
        'Limits', [0 100], ...
        'RoundFractionalValues', 'off');

    slider.ValueChangingFcn = @(~, event) setChangingValue(field, event.Value);
    slider.ValueChangedFcn = @(~, ~) setChangedValue(slider, field, callback);
    field.ValueChangedFcn = @(~, ~) setFieldValue(slider, field, callback);

    control = struct();
    control.Slider = slider;
    control.Field = field;
end

function setChangingValue(field, value)
    field.Value = snapToTwoPercent(value);
end

function setChangedValue(slider, field, callback)
    value = snapToTwoPercent(slider.Value);
    slider.Value = value;
    field.Value = value;
    callback();
end

function setFieldValue(slider, field, callback)
    field.Value = min(max(field.Value, 0), 100);
    slider.Value = snapToTwoPercent(field.Value);
    callback();
end

function value = snapToTwoPercent(value)
    value = min(max(2 * round(value / 2), 0), 100);
end
