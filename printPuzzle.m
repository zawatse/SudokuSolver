function printPuzzle(puzzle)
    fprintf('\n');
    [R, C] = size(puzzle);
    for i = 1:R
        for j = 1:C
            printNum(puzzle(i,j), j);
        end
        printRow(i);
    end
    fprintf('\n');
end

function printNum(num, j)
    rem = mod(j,3);
    if(rem == 1 && j ~= 1)
        if(num == 0)
            fprintf('|   ');
        else
            fprintf('| %d ', num);
        end
    else
        if(num == 0)
            fprintf('  ');
        else
            fprintf('%d ', num);
        end
    end
end

function printRow(i)
    rem = mod(i,3);
    if(rem == 0 && i ~= 9 )
        fprintf('\n%s\n','---------------------');
    else
        fprintf('\n');
    end
end