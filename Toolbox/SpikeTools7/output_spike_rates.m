function output = output_spike_rates(cluster)
%
% last modified 3/27/2001 --WA


[SpikeInfo SpikeFileHeader SpikeVarHeader SpikeData] = spikestat;
directories

if cluster < 1000,
   cluster = SpikeInfo.NeuronID(cluster);
end

epoch_start_codes = [9    23   24 ];
epoch_offsets =     [1000 000  200];
epoch_durations =   [1000 500  800];
desired_response = 0; %response_error value

filename = SpikeInfo.FileName;
slash = find(filename == filesep);
if ~isempty(slash),
   filename = filename(max(slash)+1:length(filename));
end
outfile = strrep(filename, '.spk', num2str(cluster));
outfile = strcat(dir_output, outfile, '.txt');
fid = fopen(outfile, 'w');
if fid < 0,
   error('********* Error opening output file ************');
   return
end

number_of_epochs = length(epoch_start_codes);
trials = find(SpikeInfo.ResponseError == desired_response);
data_matrix = zeros(length(trials), 4+number_of_epochs);
data_matrix(:, 1) = SpikeInfo.ConditionNumber(trials);
data_matrix(:, 2) = SpikeInfo.BlockNumber(trials);
data_matrix(:, 3) = SpikeInfo.RepeatNumber(trials);
data_matrix(:, 4) = ones(length(trials), 1)*desired_response;

fprintf(fid, 'Condition\tBlock\tRepeat\tResponseError\t');
for e = 1:number_of_epochs,
   data_matrix(:, 4+e) = getspikerates(trials, cluster, epoch_start_codes(e), epoch_offsets(e), epoch_durations(e));
   fprintf(fid, 'Epoch #%i\t', e);
end
fprintf(fid, '\r\n');

for row = 1:length(trials),
   numbers = data_matrix(row, :);
   fprintf(fid, '%3.3f\t', numbers);
   fprintf(fid, '\r\n');
end

fclose(fid);
output = data_matrix(:, 5:number_of_epochs);
disp(sprintf('Created %s\r\n', outfile))
a = 1;
b = 2;
c = 3;