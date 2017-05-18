function [ DataStruct ] = formatS1S2_NBI( DataStruct )

% Data where we work
data1 = DataStruct.TaskData.RR.Data;

target_idx = strcmp(data1(:,1),'Target');
target_idx(1) = 1; % StartTime
target_idx(end) = 1; % StopTime

% data2 = data1 where first column is 'Target'
data2 =  data1(target_idx,:);

% Re-compute durations
onsets              = cell2mat( data2 (:,2) ); % Get the times
duration            = diff(onsets);               % Compute the differences
data2(1:end-1,3)     = num2cell( duration );       % Save durations
% For the last event, usually StopTime, we need an exception.
if strcmp( data2{end,1} , 'StopTime' )
    data2{end,3} = 0;
end

% Where is the block end
newBlock_idx = find(cell2mat(data2(:,3)) > 2*DataStruct.PTB.IFI);

% block1 is data2 transformed into blocks
block1 = cell(length(newBlock_idx),3);
for b = 1 : length(newBlock_idx)-1
    block1{b,1} = 'Target';
    block1{b,2} = data2{newBlock_idx(b)+1,2};
    block1{b,3} = sum( cell2mat( data2(newBlock_idx(b)+1 : newBlock_idx(b+1)-1,3) ) ) + DataStruct.PTB.IFI;
end

block1 = [ data2(1,:) ; block1 ];
block1(end,:) = data2(end,:);

% Save the new block
DataStruct.TaskData.RR.Data = block1;

end
