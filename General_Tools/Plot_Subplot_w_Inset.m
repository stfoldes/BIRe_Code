% fig = Plot_Subplot_w_Inset(inset_fig_list,num_col)
%
% This uses my function Plot_Inset to do subplotting
% currently this is just a code saver, but it can be made into a real function
% Doesn't work for too many figures
%
% Foldes 2012-10-05

% NOT SURE THIS WORKS

function fig = Plot_Subplot_w_Inset(inset_fig_list,num_col)

fig = figure;hold all
axis off

set(gcf,'Position',get(gcf,'Position').*[0 1 3 1])


for iinset=1:length(inset_fig_list)
    
    
    [org_pos]=get(get(inset_fig_list(iinset),'Children'),'Position');
    org_width=org_pos(3);
    
    inset_size=(1/num_col)/(org_width/2);
    
    
%     inset_size =(1/num_col)/2;
    Plot_Inset(fig,inset_fig_list(iinset),inset_size,((1+mod(iinset-1,num_col))/num_col),1-(inset_size*7)*floor((iinset-1)/num_col));

end
axis off






