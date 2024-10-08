%% Plot the R-based Sampling Results
clear

data_type = 1; %%: ascending; 2: descending


if data_type ==1
    load('/Volumes/T7/Research/PamirProject/real_data/SEN/asc/tri_output/X.txt')
    load('/Volumes/T7/Research/PamirProject/real_data/SEN/asc/tri_output/Y.txt')
    load('/Volumes/T7/Research/PamirProject/real_data/SEN/asc/tri_output/data.txt')
    figure()
    scatter(X,Y,20,data,'filled');
    colormap jet
    colorbar
    title('R-based Sampling - Ascending')
    xlabel('km')
    ylabel('km')
end

if data_type ==2
    load('/Volumes/T7/Research/PamirProject/real_data/SEN/des/tri_output/X.txt')
    load('/Volumes/T7/Research/PamirProject/real_data/SEN/des/tri_output/Y.txt')
    load('/Volumes/T7/Research/PamirProject/real_data/SEN/des/tri_output/data.txt')
    figure()
    scatter(X,Y,20,data,'filled');
    colormap jet
    colorbar
    title('R-based Sampling - Descending')
    xlabel('km')
    ylabel('km')
end
