% Clear memory and the command window
clear; clc; 

% Establish some default variables for file types and file operations
% ------------------------ DO NOT EDIT ------------------------------
def.CNT = '.cnt'; def.PSYDAT = '.psydat'; def.DAT = '.dat'; def.TXT = '.txt'; def.SET = '.set'; def.PNG = '.png'; def.ERP = '.erp'; def.TSV = '.tsv'; def.CSV = '.csv'
def.unde = '_'; def.dash = '-';
def.path = 'Z:\Studies\PreschoolMath\HRdata'; idcs = strfind(def.path,filesep); def.path = strcat(def.path(1:idcs(end)-1),filesep);
def.folder1 = 'Raw\'; def.folder2 = 'Reduction\'; def.folder2b = 'Errors\'; def.folder3 = 'ICA\'; def.folder4 = 'Preaverages\'; def.folder5 = 'Averages\'; def.folder6 = 'GrandAverages\'; def.folder7 = 'Batch\';
% ------------------- END DO NOT EDIT --------------------------

% Name HR file PM100E

includelist = [141];

% Select time of interest for exercise condition
elapsed_min = [11.5,31.1]; % [exercise start, exercise end] put time elapsed from run sheet in minutes [5,25] - indicates exercise was from min 5 to min 25 of entire exp session
elapsed_sec = [elapsed_min*60] %convert time stamp elapsed to seconds

% Variables for file writing
startRow = elapsed_sec(1)
endRow = elapsed_sec(2)
% delimiter = {',',';'}


% Establishes a loop for the file prefix
for prefix = { 'PM' }
    for participantnumber = includelist;
        participant = num2str(sprintf('%03d', participantnumber));
            for condition = {'C'}
                filein = strcat(def.path, 'HRdata\', cell2mat(prefix), participant, cell2mat(condition), def.CSV);
                if (exist(filein, 'file') > 0) % if file exists
                    [pathstr,name,ext] = fileparts(filein);
                    
                    fileID = fopen(filein,'r');
                    dataArray = textscan(fileID, '%f%f%[^\n\r]', 'Delimiter', {','}, 'TextType', 'string', 'EmptyValue', NaN, 'HeaderLines' , 8, 'ReturnOnError', false, 'EndOfLine', '\r\n');
                    fclose(fileID);
                    
%                     textscan(fileID, '%[^\n\r]', startRow(1)-1, 'WhiteSpace', '', 'ReturnOnError', false);
%                     dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN, 'ReturnOnError', false, 'EndOfLine', '\r\n');
                    for block=2:length(startRow)
                        frewind(fileID);
                        textscan(fileID, '%[^\n\r]', startRow(block)-1, 'WhiteSpace', '', 'ReturnOnError', false);
                        dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN, 'ReturnOnError', false, 'EndOfLine', '\r\n');
                        for col=1:length(dataArray)
                            dataArray{col} = [dataArray{col};dataArrayBlock{col}];
                        end
                    end
                    
                    
                   % Create output variables
                    dataArray = cellfun(@(x) num2cell(x), dataArray, 'UniformOutput', false);
                    raw = [dataArray{1:end-1}];
                   
                   % Create output matrix for writing to file
                    raw_mat = cell2mat(raw)
%                    raw_mat(:,2) = raw_mat(:,2)/2 % divide second column by 10 to get partial seconds
%                   time_mat = [(raw_mat(:,1) + raw_mat(:,2)) raw_mat(:,3)]; % add columns 1 & 2 to get total partial seconds  
%                   new_mat = time_mat(time_mat(:,1) >= startRow & time_mat(:,1) <= endRow,:); % create new matrix with total time and bpm
                   
                 
                   % Export Data to File
                   filout = strcat(def.path, 'HRdata\', cell2mat(prefix), participant, cell2mat(condition), '_test.csv');

                   fid = fopen(filout, 'wt');
                   %fprintf(fid, '%s\n,', strcat(cell2mat(prefix), participant, cell2mat(condition)));
                   fprintf(fid, '%s%s\n', 'Time_sec', 'Heart_rate'); % header                   
                   dlmwrite(filout, raw_mat, '-append')
%                    for i = 1:length(new_mat);
%                    fprintf(fid, '%s,', strcat(cell2mat(prefix), participant));
%                    fprintf(fid, ',');
%                    fprintf(fid, '%d', new_mat(:,1));
%                    fprintf(fid, ',');
%                    fprintf(fid, '%d', new_mat(:,2));
%                    fprintf(fid, '\n', new_mat(:,1));
%                    end
                   fclose(fid);
                   
                   
                   
                end % if file exists
            end % condition
    end % participant
end % study          
