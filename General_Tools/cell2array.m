function array_data = cell2array(cell_data)
% Translates a 1D cell-array into an array, given each cell has equal sized parts
% In the new array, the last dimension is the cell-dimension
% EXAMPLE: data{10}(7x100) --> data(7x100x10)
%
% 2013-12-06 Foldes
% UPDATES:
%

for icell = 1:length(cell_data)
    all_cell_sizes(icell,:) = size(cell_data{icell});
end
num_dims = min(size(all_cell_sizes)); % number of dimensions

% if all sizes are the same
if length(unique(all_cell_sizes)) == num_dims
    array_data = [];
    for icell = 1:length(cell_data)
        array_data = cat(num_dims+1,array_data,cell_data{icell});
    end
else
    warning('Not able to translate cell into an array')
    array_data = cell_data;
end
