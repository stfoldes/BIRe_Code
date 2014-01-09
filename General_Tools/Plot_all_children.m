% Plot All Children Of Given Structure
% Stephen Foldes 02-15-11
% UPDATES
% 2012-01-10 SF

function plot_all_children(input_struct)

current_fields=fields(input_struct);

for ifield = 1:size(current_fields,1)
    try
        figure;
        eval(['plot(input_struct.' current_fields{ifield} ',''.-'')'])
        eval(['title(''' current_fields{ifield} ''')'])
    catch
        text(0.1,0.5,['Could not plot: '  current_fields{ifield}],'FontSize',12);
        axis off
    end
end