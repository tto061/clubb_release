function PlotCreator( caseName, plotTitle, plotNum, plotType, startTime, endTime, startHeight, endHeight, plotUnits, tickCount, varargin )

%Display the variables that were passed in (debug output)
caseName
plotTitle
plotUnits
plotNum
plotType
startTime
endTime
startHeight
endHeight

%Define a padding
maxTextLength = 20;

%Figure out the number of optional arguments passed in
optargin = size(varargin,2);

%Optional argument format is as follows:
%'/PATH/TO/FILE', 'timeseries or profile', 'varname', 'title', 'units', 'lineWidth', 'lineType', 'lineColor'

%This means we can easily figure out the number of lines on the plot by dividing by 8
numLines = optargin / 7;

%Create a blank plot of the proper type so we have somewhere to draw lines
% Figure Properties for screen display.
scr_size = get(0,'ScreenSize');
fig_height = scr_size(4);
fig_width = (6.5/9.0) * fig_height;
fig_width = int16(fig_width);

% Open figure to set size.
figure('Position',[ 0 0 fig_width fig_height ])
set(gcf, 'PaperPositionMode', 'manual')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperPosition', [ 1.0 1.0 6.5 9.0 ])

%Preallocate the arrays needed for legend construction
lines(1:numLines) = 0; %This is the collection where lines are stored
clear legendText;

%Loop through each line on the plot
for i=1:numLines
	filePath = varargin{1 * i};
	varName = varargin{2 * i};
	varExpression = varargin{3 * i};
	lineName = varargin{4 * i};
	lineWidth = str2num(varargin{5 * i});
	lineType = varargin{6 * i};
	lineColor = varargin{7 * i};

	%Determine the type of file being read in
	extension = DetermineExtension(filePath);

	%Determine the variables that need to be read in
	varsToRead = ParseVariablesFromExpression(varExpression);

	%Read in the necessary variables
	for j=1:size(varsToRead,2);
		%We need to convert the variable name to read from a cell array to a string
		varString = cell2mat(varsToRead(j));
		disp(['Reading variable ', varString]);

		if strcmp(extension, 'ctl')
			[variableData, levels] = VariableReadGrADS(filePath, varString, startTime, endTime);
		elseif strcmp(extension, 'nc')
			[variableData, levels] = VariableReadNC(filePath, varString, startTime, endTime);
		end

		%Store the read in values to the proper variable name (ex. variable rtm will be read in to the variable named rtm,
		%this allows the expression to be used as is).
		eval([varString, '= variableData;']);
	end

	%Read in time and height
	%We need to convert the variable name to read from a cell array to a string
	if strcmp(extension, 'ctl')
		[timeData, levels] = VariableReadGrADS(filePath, 'time', startTime, endTime);
		[heightData, levels] = VariableReadGrADS(filePath, 'height', startTime, endTime);
	elseif strcmp(extension, 'nc')
		[timeData, levels] = VariableReadNC(filePath, 'time', startTime, endTime);
		[heightData, levels] = VariableReadNC(filePath, 'height', startTime, endTime);
	end

	%Now evaluate the expression using the read in values,
	eval(['valueToPlot =', varExpression, ';']);
	
	%At this point, the value of the expression is contained in valueToPlot

	%Add a legend and scale the axis
	if strcmp(plotType, 'profile')
		lines(i) = ProfileFunctions.addLine(lineName, levels, valueToPlot, lineWidth, lineType, lineColor);
		legendText(i,1:size(lineName,2)) = lineName;
		
		ProfileFunctions.setTitle(plotTitle);
		ProfileFunctions.setAxisLabels(plotUnits, '[m]'); 
		ProfileFunctions.addLegend(lines, legendText);
		ProfileFunctions.setAxis(min(valueToPlot), max(valueToPlot), startHeight, endHeight);
	elseif strcmp(plotType, 'timeseries')

	end
end

%Output the EPS file
mkdir([ 'output_', int2str(tickCount)]);
output_file_name = [ 'output_', int2str(tickCount), '/', caseName, '_', int2str(plotNum), '.eps' ];
print( '-depsc2', output_file_name );
