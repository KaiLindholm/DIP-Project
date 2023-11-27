function output_csv_1(mask_number, centroidX, centroidY, radius)

end

function writeToCSV(mask_number, centroidX, centroidY, radius)
    % Check if the file exists
    filename = 'g1_part1.csv';
    
    if exist(filename, 'file') ~= 2
        error('File does not exist');
    end
    
    % Read existing data from CSV
    existingData = csvread(filename);

    % Check if rowNum is within bounds
    numRows = size(existingData, 1);
    if rowNum < 1 || rowNum > numRows + 1
        error('Row number out of bounds');
    end

    % Insert the new row of data at the specified position
    newData = [existingData(1:rowNum-1, :); data; existingData(rowNum:end, :)];

    % Write the updated data back to the CSV file
    csvwrite(filename, newData);
end
