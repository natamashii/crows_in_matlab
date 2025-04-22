function [converted] = cell_convert(data)

% identify longest entry of cell
sizes = cell2mat(cellfun(@size, data, 'uni', false));
row_sizes = sizes(2:2:end);
[~, max_x] = max(row_sizes);


% pre allocation
converted = {};
% iterate over all entries & pad NaN to them
for entry = 1:numel(data)
    element = data{entry};
    padded = NaN(size(element, 1), row_sizes(max_x));
    padded(1:size(element, 1), 1:size(element, 2)) = element;
    converted{end + 1} = padded;
end

% convert to array
converted = vertcat(converted{:});

end