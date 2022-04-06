function y = write_err_line(err_file,x, expected, actual, err, InpValues, FixP, QType, ImplSpeed)
if ~exist('ImplSpeed')
    ImplSpeed = 'n\a';
end
empty_line = char(32*ones(1,150));
temp = 1:length(err);
idx = temp(err ~= 0);
%idx = (err ~= 0);
fid = fopen(err_file,'a');
testcase = [x ': A_FixP={' num2str(FixP{1,1}{1}) ',' num2str(FixP{1,1}{2}) ',' num2str(FixP{1,1}{3}) ...
               '}, B_FixP={' num2str(FixP{1,2}{1}) ',' num2str(FixP{1,2}{2}) ',' num2str(FixP{1,2}{3}) ...
               '}, Shift_FixP={' num2str(FixP{1,3}{1}) ',' num2str(FixP{1,3}{2}) ',' num2str(FixP{1,3}{3}) ...
               '}, Out_FixP={' num2str(FixP{1,4}{1}) ',' num2str(FixP{1,4}{2}) ',' num2str(FixP{1,4}{3}) ...
               '}, QuantType=' QType ', ImplSpeed=' ImplSpeed '\n'];
fprintf(fid, testcase);
disp('ERROR in:')
disp(testcase)
head_line = empty_line;
head_line(1) = 'A';
head_line(31) = 'B';
head_line(61:65) = 'Shift';
head_line(91:98) = 'expected';
head_line(121:126) = 'actual';
fprintf(fid,[head_line '\n']);
disp(head_line)
for k = idx
    err_line = empty_line;
    A = num2str(InpValues(k,1));
    B = num2str(InpValues(k,2));
    S = num2str(InpValues(k,3));
    Exp = num2str(expected(k));
    Act = num2str(actual(k));
    err_line(1:length(A)) = A;
    err_line(31:30+length(B)) = B;
    err_line(61:60+length(S)) = S;
    err_line(91:90+length(Exp)) = Exp;
    err_line(121:120+length(Act)) = Act;
    fprintf(fid,[err_line '\n']);
    disp(err_line)
end
fprintf(fid,'\n');
%                'A       : ' num2str(InpValues(idx,1).') '\n' ...
%                'B       : ' num2str(InpValues(idx,2).') '\n' ...
%                'Shift   : ' num2str(InpValues(idx,3).') '\n' ...
%                'expected: ' num2str(expected(idx).') '\n' ...
%                'actual  : ' num2str(actual(idx).') '\n\n']);
fclose(fid);