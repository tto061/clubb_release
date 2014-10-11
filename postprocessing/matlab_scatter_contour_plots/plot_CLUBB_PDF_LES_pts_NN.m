% $Id$
function plot_CLUBB_PDF_LES_pts_NN( var_x_LES, var_y_LES, nx_LES_grid, ...
                                    ny_LES_grid, num_x_pts, num_y_pts, ...
                                    mu_x_1, mu_x_2, mu_y_1, mu_y_2, ...
                                    sigma_x_1, sigma_x_2, sigma_y_1, ...
                                    sigma_y_2, corr_x_y_1, ...
                                    corr_x_y_2, mixt_frac, ...
                                    var_x_label, var_y_label, ...
                                    case_name, fields_plotted, ...
                                    time_plotted, ...
                                    altitude_plotted, ...
                                    note )
                                
% Path to PDF analysis functions.
addpath ( '../../utilities/PDF_analysis', '-end' )

scr_size= get(0,'ScreenSize');
fig_height = 0.9*scr_size(4);
fig_width  = fig_height;
figure('Position',[ 0 0 fig_width fig_height ])

subplot( 'Position', [ 0.1 0.75 0.55 0.2 ] )

% Histogram and marginal for x, a variable that is distributed normally in
% each PDF component.
min_x = min( var_x_LES );
max_x = max( var_x_LES );
num_x_divs = num_x_pts + 1;
delta_x = ( max_x - min_x ) / num_x_pts;
x_divs = zeros( num_x_divs, 1 );
x = zeros( num_x_pts, 1 );
P_x = zeros( num_x_pts, 1 );
% Calculate the x "division points" (edges of the bins).
for i = 1:1:num_x_divs
   x_divs(i) = min_x + delta_x * ( i - 1 );
end
% Calculate the x points (center of each bin).
for i = 1:1:num_x_pts
   x(i) = 0.5 * ( x_divs(i) + x_divs(i+1) );
end
% CLUBB's PDF marginal for x.
for i = 1:1:num_x_pts
   P_x(i) ...
   = mixt_frac * PDF_comp_Normal( x(i), mu_x_1, sigma_x_1 ) ...
     + ( 1.0 - mixt_frac ) * PDF_comp_Normal( x(i), mu_x_2, sigma_x_2 );
end
% Centerpoints and counts for each bin (from LES results) for x.
binranges_x = x;
[bincounts_x] = histc( var_x_LES, binranges_x );
% Plot normalized histogram of LES results for x.
bar( binranges_x, bincounts_x / ( nx_LES_grid * ny_LES_grid ), 1.0, ...
     'r', 'EdgeColor', 'r' );
hold on
% Plot normalized PDF of x for CLUBB.
plot( x, P_x * delta_x, '-b', 'LineWidth', 2 )
hold off
% Set the range of the plot on both the x-axis and y-axis.
xlim( [ min_x max_x ] )
ylim( [ 0 max( max(bincounts_x) / ( nx_LES_grid * ny_LES_grid ), ...
          max(P_x) * delta_x ) ] );
%xlabel( var_x_label )
legend( 'LES', 'CLUBB', 'Location', 'NorthEast' )
grid on
box on

subplot( 'Position', [ 0.75 0.1 0.2 0.55 ] )

% Histogram and marginal for y, a variable that is distributed normally in
% each PDF component.
min_y = min( var_y_LES );
max_y = max( var_y_LES );
num_y_divs = num_y_pts + 1;
delta_y = ( max_y - min_y ) / num_y_pts;
y_divs = zeros( num_y_divs, 1 );
y = zeros( num_y_pts, 1 );
P_y = zeros( num_y_pts, 1 );
% Calculate the y "division points" (edges of the bins).
for j = 1:1:num_y_divs
   y_divs(j) = min_y + delta_y * ( j - 1 );
end
% Calculate the y points (center of each bin).
for j = 1:1:num_y_pts
   y(j) = 0.5 * ( y_divs(j) + y_divs(j+1) );
end
% CLUBB's PDF marginal for y.
for j = 1:1:num_y_pts
   P_y(j) ...
   = mixt_frac * PDF_comp_Normal( y(j), mu_y_1, sigma_y_1 ) ...
     + ( 1.0 - mixt_frac ) * PDF_comp_Normal( y(j), mu_y_2, sigma_y_2 );
end
% Centerpoints and counts for each bin (from LES results) for y.
binranges_y = y;
[bincounts_y] = histc( var_y_LES, binranges_y );
% Plot normalized histogram of LES results for y.
bar( binranges_y, bincounts_y / ( nx_LES_grid * ny_LES_grid ), 1.0, ...
     'r', 'EdgeColor', 'r' );
hold on
% Plot normalized PDF of y for CLUBB.
plot( y, P_y * delta_y, '-b', 'LineWidth', 2 )
hold off
% Set the range of the plot on both the x-axis and y-axis.
xlim( [ min_y max_y ] )
ylim( [ 0 max( max(bincounts_y) / ( nx_LES_grid * ny_LES_grid ), ...
          max(P_y) * delta_y ) ] );
%xlabel( var_y_label )
% Reverse the plot and turn the plot 90 degrees clockwise.
set(gca, 'xdir', 'reverse')
view( [90, 90] )
grid on
box on

subplot( 'Position', [ 0.1 0.1 0.55 0.55 ] )

% Scatterplot and contour plot for x and y.
P_xy = zeros( num_y_pts, num_x_pts );
% CLUBB's PDF of x and y, where y > 0.
for i = 1:1:num_x_pts
   for j = 1:1:num_y_pts
      P_xy(j,i) ...
      = mixt_frac ...
        * PDF_comp_bivar_NN( x(i), y(j), mu_x_1, mu_y_1, ...
                             sigma_x_1, sigma_y_1, corr_x_y_1 ) ...
        + ( 1.0 - mixt_frac ) ...
          * PDF_comp_bivar_NN( x(i), y(j), mu_x_2, mu_y_2, ...
                               sigma_x_2, sigma_y_2, corr_x_y_2 );
   end
end
% Scatterplot of LES results for x and y.
scatter( var_x_LES, var_y_LES, ...
         'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r' )
hold on
% Contour plot of the PDF of x and y for CLUBB.
contour( x, y, P_xy, 2500, 'Linewidth', 1.5 )
legend( 'LES', 'CLUBB', 'Location', 'NorthEast' )
hold off
% Set the range of the plot on both the x-axis and y-axis.
xlim([min_x max_x])
ylim([min_y max_y])
xlabel( var_x_label )
ylabel( var_y_label )
grid on
box on

% Figure title and other important information.
figure_title_text = { case_name; fields_plotted; time_plotted; ...
                      altitude_plotted; note };

axes( 'Position', [0 0 1 1], 'Xlim', [0 1], 'Ylim', [0 1], ...
      'Box', 'off', 'Visible', 'off', 'Units', 'normalized', ...
      'clipping', 'off' );

text( 0.825, 0.95, figure_title_text, ...
      'HorizontalAlignment', 'center', 'VerticalAlignment', 'top' );