%% 1.1


txt = fileread ('mobydick.txt');
symb = intersect (txt,txt);
n =length(symb);

for i=1:n
    Dist_single(i).symb = symb(i);
    k = strfind(txt,Dist_single(i).symb);
    Dist_single(i).prob = length(k)/length(txt);
end 
 % entropy calculation
H1 = -sum([Dist_single.prob].*log2([Dist_single.prob]));


%% 1.2


txt = fileread ('mobydick.txt');
symb = intersect (txt,txt);
n =length(symb);
t = 1;

for i=1:n
    for j=1:n
        k = strfind(txt,[symb(i) symb(j)]);
        if ~isempty(k) % get rid of zero prob pairs (log is not defined)
            Dist_pair(t).symb = [symb(i) symb(j)];
            Dist_pair(t).prob = length(k)/(length(txt));
            t = t+1;
        end 
    end
end 


% entropy calculation
H2 = -sum([Dist_pair.prob].*log2([Dist_pair.prob]));
H2 = H2/2; % to get the entropy per charecter

%% 1.3

%  conditionl entropy calculation

Hc = 0;

for i=1:length(Dist_pair)
    p_both  = Dist_pair(i).prob;
    ind = strfind([Dist_single.symb],Dist_pair(i).symb(1));
    p_first = Dist_single(ind).prob;
    Hc = Hc - p_both*log2(p_both/ p_first);
end

    
    