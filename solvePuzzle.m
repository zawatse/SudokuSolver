function postPuzzle = solvePuzzle(puzzle)
    unchanged = false;

    % Create a 3D representation of the puzzle where the third dimension
    % represents each of the possible 9 numbers. A 1 represents that number
    % is still possible, a 0 indicates it is not possible any longer given
    % the rules that have been applied
    puzzleRep = convertPuzzle(puzzle);

    % A loop that will apply all of our rules continually. If the puzzle is
    % solved, or if the puzzle remations unchanged, we end the loop
    while(checkSolved(puzzleRep) ~= 1 && unchanged == false)
        preRules = puzzleRep;
        
        % This function will check if a space has been determined, and if
        % so, will eliminate the value of that space from the possible
        % values list for each space in the same row, column, and square of
        % that space
        puzzleRep = RowColumnSquareCheckEliminate(puzzleRep);

        % This function determins if a space is the last in a row, column
        % or square that can be assigned a certain value, and if so,
        % assigns it that value
        puzzleRep = ProcessOfElimination(puzzleRep);

        % If you can determine that a number must be in a specific row or column of
        % a square, you can eliminate that number from the rest of that row or
        % column
        puzzleRep = SquareRowAndColumnEliminator(puzzleRep);

        % If we can narrow down the possibilities for any two numbers to the same two 
        % spaces in a sqaure, row, or column, then we can eliminate all other
        % options in those spaces
        puzzleRep = InterlockedPairsFinder(puzzleRep);

        if(preRules == puzzleRep)
            unchanged = true;
        end
    end
    if(checkSolved(puzzleRep) ~= 1)
        fprintf('Unable to solve');
    end

    % Convert puzzle from 3D representation back into a human readable
    % format
    postPuzzle = revertPuzzle(puzzleRep);
end

function solved = checkSolved(puzzleRep)
    solved = 0;
    [R,C,D] = size(puzzleRep);
    for i = 1:R
        for j = 1:C
            if (sum(puzzleRep(i,j,:)) ~= 1)
                return;
            end
        end
    end
    solved = 1;
end

function puzzleRep = convertPuzzle(puzzle)
    [R,C] = size(puzzle);
    puzzleRep = zeros(R,C,9);
    for i = 1:R
        for j = 1:C
            if(puzzle(i,j) ~= 0)
                puzzleRep(i,j,puzzle(i,j)) = 1;
            else
                for k = 1:9
                    puzzleRep(i,j,k) = 1;
                end
            end
        end
    end
end

function puzzle = revertPuzzle(puzzleRep)
    [R,C,D] = size(puzzleRep);
    puzzle = zeros(R,C);
    for i = 1:R
        for j = 1:C
            if(sum(puzzleRep(i,j,:)) ~= 1)
                puzzle(i,j) = 0;
            else
                for k = 1:9
                    if(puzzleRep(i,j,k) == 1)
                        puzzle(i,j) = k;
                    end
                end
            end
        end
    end
end

function puzzleRep = RowColumnSquareCheckEliminate(puzzleRep)
    [R,C,D] = size(puzzleRep);
    for i = 1:R
        for j = 1:C
            if(sum(puzzleRep(i,j,:)) == 1)
                num = find(puzzleRep(i,j,:) == 1);

                %  Eliminate from columns
                puzzleRep(:,j,num) = 0;

                % Eliminate from rows
                puzzleRep(i,:,num) = 0;

                % Eliminate from square
                squareRowStart = fix((i-1)/3)*3+1;
                squareColStart = fix((j-1)/3)*3+1;
                puzzleRep(squareRowStart:(squareRowStart+2),squareColStart:(squareColStart+2),num) = 0;
                
                % replace number
                puzzleRep(i,j,num) = 1;
            end
        end
    end
end

function puzzleRep = ProcessOfElimination(puzzleRep)
    [R,C,D] = size(puzzleRep);
    % Check each row to see if any value has only one possible place
    for i = 1:R
        for j = 1:D
            pos = find(puzzleRep(i,:,j));
            if(length(pos) == 1 && sum(puzzleRep(i,pos,:)) ~= 1)
                puzzleRep(i,pos,:) = 0;
                puzzleRep(i,pos,j) = 1;
            end
        end
    end

    % Check each column to see if any value has only one possible place
    for i = 1:C
        for j = 1:D
            pos = find(puzzleRep(:,i,j));
            if(length(pos) == 1 && sum(puzzleRep(pos,i,:)) ~= 1)
                puzzleRep(pos,i,:) = 0;
                puzzleRep(pos,i,j) = 1;
            end
        end
    end

    % Check each square to see if any value has only one possible place
    for x = 0:2
        for y = 0:2
            square = puzzleRep((3*x+1):(3*x+3),(3*y+1):(3*y+3),:);
            for j = 1:9
                [R,C] = find(square(:,:,j));
                if(length(R) == 1 && sum(square(R,C,:)) ~= 1)                        
                    square(R,C,:) = 0;
                    square(R,C,j) = 1;
                end
            end
            puzzleRep((3*x+1):(3*x+3),(3*y+1):(3*y+3),:) = square;
        end
    end
end

% General idea:
% If you can determine that a number must be in a specific row or column of
% a square, you can eliminate that number from the rest of that row or
% column

% Methodology:
% Designate a square
% Designate a row/column overlapping said square
% For each number, check the positions in the non-overlapping region of the square
% If all positions are 0, set all positions in the non-overlapping region of the row/column to 0
function puzzleRep = SquareRowAndColumnEliminator(puzzleRep)
    for x = 0:2
        for y = 0:2
            square = puzzleRep((3*x+1):(3*x+3),(3*y+1):(3*y+3),:);
            % Check each row
            for row = (3*x+1):(3*x+3)
                for j = 1:9
                    if(sum(square(:,:,j), "all") - sum(puzzleRep(row,(3*y+1):(3*y+3),j)) == 0)                        
                        rowSnippet = puzzleRep(row,(3*y+1):(3*y+3),j);
                        puzzleRep(row,:,j) = 0;
                        puzzleRep(row,(3*y+1):(3*y+3),j) = rowSnippet;
                    end
                end
            end
            % Check each column
            for col = (3*y+1):(3*y+3)
                for j = 1:9
                    if(sum(square(:,:,j),"all")-sum(puzzleRep((3*x+1):(3*x+3),col,j)) == 0)                        
                        colSnippet = puzzleRep((3*x+1):(3*x+3),col,j);
                        puzzleRep(:,col,j) = 0;
                        puzzleRep((3*x+1):(3*x+3),col,j) = colSnippet;
                    end
                end
            end
        end
    end
end

% General Idea:
% If we can narrow down the possibilities for any two numbers to the same two 
% spaces in a sqaure, row, or column, then we can eliminate all other
% options in those spaces
%
% Methodology:
% Grab a row, column, or square
% Find all numbers for which we only have two possible spaces left
% check all combinations of these numbers to see if any share the same set
% of spaces
% if any do, eliminate all other numbers in those spaces
function puzzleRep = InterlockedPairsFinder(puzzleRep)
    [R,C,D] = size(puzzleRep);
    % Check each row 
    for i = 1:R
        nums = [];
        for j = 1:D
            if(sum(puzzleRep(i,:,j), "all") == 2)
                nums(end+1) = j;
            end
        end
        for a = 1:length(nums)
            for b = 1:length(nums)
                x = puzzleRep(i,:,nums(a));
                y = puzzleRep(i,:,nums(b));
                if(a~=b && isequal(x,y))
                    c = find(puzzleRep(i,:,nums(a)));
                    puzzleRep(i,c(1),:) = 0;
                    puzzleRep(i,c(2),:) = 0;
                    puzzleRep(i,c(1),nums(a)) = 1;
                    puzzleRep(i,c(1),nums(b)) = 1;
                    puzzleRep(i,c(2),nums(a)) = 1;
                    puzzleRep(i,c(2),nums(b)) = 1;                    
                end
            end
        end
    end
    % Check each col 
    for i = 1:C
        nums = [];
        for j = 1:D
            if(sum(puzzleRep(:,i,j), "all") == 2)
                nums(end+1) = j;
            end
        end
        for a = 1:length(nums)
            for b = 1:length(nums)
                x = puzzleRep(:,i,nums(a));
                y = puzzleRep(:,i,nums(b));
                if(a~=b && isequal(x,y))
                    c = find(puzzleRep(:,i,nums(a)));
                    puzzleRep(c(1),i,:) = 0;
                    puzzleRep(c(2),i,:) = 0;
                    puzzleRep(c(1),i,nums(a)) = 1;
                    puzzleRep(c(1),i,nums(b)) = 1;
                    puzzleRep(c(2),i,nums(a)) = 1;
                    puzzleRep(c(2),i,nums(b)) = 1;                    
                end
            end
        end
    end
    % Check each square
    for x = 0:2
        for y = 0:2
            square = puzzleRep((3*x+1):(3*x+3),(3*y+1):(3*y+3),:);
            nums = [];
            for j = 1:D
                if(sum(square(:,:,j), "all") == 2)
                    nums(end+1) = j;
                end
            end
            for a = 1:length(nums)
                for b = 1:length(nums)
                    e = square(:,:,nums(a));
                    f = square(:,:,nums(b));
                    if(a~=b && isequal(e,f))
                        [c,d] = find(square(:,:,nums(a)));
                        square(c(1),d(1),:) = 0;
                        square(c(2),d(2),:) = 0;
                        square(c(1),d(1),nums(a)) = 1;
                        square(c(1),d(1),nums(b)) = 1;
                        square(c(2),d(2),nums(a)) = 1;
                        square(c(2),d(2),nums(b)) = 1;                    
                    end
                end
            end
            puzzleRep((3*x+1):(3*x+3),(3*y+1):(3*y+3),:) = square;
        end
    end
end
